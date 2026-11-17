# 1.71 Kafka 线上协议深度解析

> **置信口径**: 协议字段与报文格式=【定理】（以 Apache Kafka Protocol Guide 为准）；版本协商、客户端兼容性与事务风险分析=【论证】；正文未单独标注的性能数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Apache Kafka 官方发布信息，核实至 2026-11。关键版本：4.0.0（2025-03-18）、4.2.0（2026-02-17）、4.3.0（2026-05-22）、4.4.0（2026-10-22）。
> **定位声明**: 本文聚焦 Kafka 二进制线上协议（wire protocol）的帧格式、ApiVersions 协商、Produce/Fetch/事务报文与版本治理；存储与复制内幕见 [1.61 Kafka 存储与复制内幕深度解析](./01-61-Kafka存储与复制内幕深度解析.md)；MQTT 全协议对比见 [1.64 MQTT 协议全解析](./01-64-MQTT-5.0协议全解析.md)。

## 目录

- [1.71 Kafka 线上协议深度解析](#171-kafka-线上协议深度解析)
  - [目录](#目录)
  - [1.71.1 协议基础](#1711-协议基础)
    - [TCP 长度前缀帧与请求头](#tcp-长度前缀帧与请求头)
    - [ApiVersions 协商流程](#apiversions-协商流程)
  - [1.71.2 消息批次 RecordBatch v2](#1712-消息批次-recordbatch-v2)
    - [批次头字段](#批次头字段)
    - [压缩与时间戳类型](#压缩与时间戳类型)
  - [1.71.3 Produce/Fetch 全字段走查](#1713-producefetch-全字段走查)
    - [Produce 请求与 acks 语义](#produce-请求与-acks-语义)
    - [Fetch 请求与推拉混合语义](#fetch-请求与推拉混合语义)
    - [Fetch 会话与增量 Fetch](#fetch-会话与增量-fetch)
  - [1.71.4 事务协议](#1714-事务协议)
    - [事务报文序列](#事务报文序列)
    - [事务标记写入数据日志的格式](#事务标记写入数据日志的格式)
    - [Jepsen 2024-11 对事务协议 unsound 的协议层解读](#jepsen-2024-11-对事务协议-unsound-的协议层解读)
  - [1.71.5 版本治理](#1715-版本治理)
    - [消息格式版本与 broker 版本](#消息格式版本与-broker-版本)
    - [客户端兼容矩阵](#客户端兼容矩阵)
  - [1.71.6 Kafka 与 MQTT 报文模型对照](#1716-kafka-与-mqtt-报文模型对照)
  - [1.71.7 抓包分析示例](#1717-抓包分析示例)
  - [1.71.8 参考来源](#1718-参考来源)

---

## 1.71.1 协议基础

### TCP 长度前缀帧与请求头

Kafka 使用自定义二进制协议跑在 TCP 之上。所有通信都是**请求-响应对**，每个连接上 broker 按请求顺序返回响应【定理：Kafka Protocol Guide】。帧格式非常简单：

```text
Request  = [4-byte size (INT32, BE)] [Request Header] [Request Body]
Response = [4-byte size (INT32, BE)] [Response Header] [Response Body]
```

长度前缀让接收方在流式 TCP 上确定报文边界；请求头中的 `api_key` 与 `api_version` 决定后续 Body 的 schema。请求头 v2 字段如下【定理：Kafka Protocol Guide】：

| 字段 | 类型 | 含义 |
| ---- | ---- | ---- |
| `api_key` | INT16 | 请求类型编号，如 `0=Produce`、`1=Fetch`、`18=ApiVersions` |
| `api_version` | INT16 | 该 API 的协议版本 |
| `correlation_id` | INT32 | 客户端自选，响应中原样返回，用于匹配异步请求 |
| `client_id` | NULLABLE_STRING | 客户端标识，便于日志与配额追踪 |
| `tagged_fields` | TAG_BUFFER | KIP-482 引入的灵活字段，v2 起使用 |

响应头更简单：v1 只有 `correlation_id` + `tagged_fields`，不再重复 `api_key/api_version`，因此客户端必须用 correlation id 恢复上下文。

下面是一个裸 ApiVersions v0 请求示例（Body 为空）：

```python
import socket, struct
s = socket.socket()
s.connect(("localhost", 9092))
client_id = b"probe"
header = struct.pack(">hhih", 18, 0, 1, len(client_id)) + client_id
frame = struct.pack(">i", len(header)) + header
s.sendall(frame)
size = struct.unpack(">i", s.recv(4))[0]
resp = s.recv(size)
print("correlation:", struct.unpack(">i", resp[:4])[0])
```

### ApiVersions 协商流程

客户端建立 TCP 后首先发送 `ApiVersions`（API key 18）。该请求特殊之处在于 broker 甚至在 SASL 认证完成前就会响应，因此客户端可以据此决定后续握手版本（KIP-35）。协商流程：

1. 客户端发送 `ApiVersionsRequest`，声明自己能接受的最高版本；
2. Broker 返回 `ApiVersionsResponse`，列出每个 API key 支持的 `[min_version, max_version]`；
3. 客户端为后续每个 API 选择**双方交集内的最高版本**；
4. 若客户端发送了 broker 不支持的版本，broker 返回 `UNSUPPORTED_VERSION`（error code 35）并通常关闭连接。

从 Kafka 4.0 起，KIP-896 删除了大量旧协议版本，broker 的协议 floor 提升到 Kafka 2.1 对应的版本范围。这意味着 4.x broker 不再接受 0.x/1.x/2.0 等古老客户端的请求。

---

## 1.71.2 消息批次 RecordBatch v2

Kafka 0.11 引入消息格式 v2（magic=2），日志和网络上传输的都是 **RecordBatch**。一个批次是一条或多条记录的容器，也是幂等、事务、压缩等机制的最小协议单元。

### 批次头字段

RecordBatch v2 的头部字段如下【定理：Kafka Message Format】：

| 字段 | 类型 | 含义 |
| ---- | ---- | ---- |
| `baseOffset` | INT64 | 批次首条记录的 offset（broker 写入时填） |
| `batchLength` | INT32 | 从当前位置到批次末尾的字节数 |
| `partitionLeaderEpoch` | INT32 | 写入该批次时的 Leader Epoch，与 01-61 的 epoch 截断机制直接相关 |
| `magic` | INT8 | 消息格式版本，v2 固定为 2 |
| `crc` | UINT32 | CRC-32C，覆盖 attributes 到批次末尾 |
| `attributes` | INT16 | 压缩类型、时间戳类型、事务/控制位 |
| `lastOffsetDelta` | INT32 | 批次内最后一条相对 offset |
| `baseTimestamp` | INT64 | 批次基准时间戳 |
| `maxTimestamp` | INT64 | 批次内最大时间戳 |
| `producerId` | INT64 | 幂等/事务生产者 ID（PID） |
| `producerEpoch` | INT16 | 生产者 epoch，用于 fencing 僵尸生产者 |
| `baseSequence` | INT32 | 该批次第一条记录的序列号 |
| `recordsCount` | INT32 | 批次内记录条数 |
| `records` | [Record] | 记录数组，压缩时整体压缩 |

`partitionLeaderEpoch` 不参与 CRC 计算，因此 broker 在分配 epoch 时无需重算 CRC。01-61 中提到的 `OffsetForLeaderEpoch` 协议正是利用这个 epoch 字段判断副本截断点。

```bash
# 使用 kafka-dump-log.sh 查看批次头（不解析 payload）
kafka-dump-log.sh --files /var/kafka-logs/orders-0/00000000000000000000.log \
  --print-data-log false | head -n 20
```

### 压缩与时间戳类型

`attributes` 低 3 位表示压缩类型，当前 Kafka 支持的压缩集为 `gzip`、`snappy`、`lz4`、`zstd`【定理：Kafka Topic Configs】。zstd 由 KIP-110 在 Kafka 2.1.0 引入。

| attributes bit 0~2 | 压缩算法 | 说明 |
| ---- | ---- | ---- |
| 0 | none | 无压缩 |
| 1 | gzip | 压缩比高，CPU 开销大 |
| 2 | snappy | 速度快，压缩比一般 |
| 3 | lz4 | 极低延迟，适合高吞吐 |
| 4 | zstd | 压缩比与速度平衡，Kafka 2.1+ |

bit 3 表示时间戳类型：

| bit 3 | 类型 | 含义 |
| ---- | ---- | ---- |
| 0 | CreateTime | 由 Producer 设置 |
| 1 | LogAppendTime | 由 Broker 在写入时设置 |

bit 4 标记事务批次（`isTransactional`），bit 5 标记控制批次（`isControlBatch`），后者用于写入 COMMIT/ABORT 事务标记。

---

## 1.71.3 Produce/Fetch 全字段走查

### Produce 请求与 acks 语义

`Produce`（API key 0）是生产者写数据的核心请求。关键字段包括：

| 字段 | 类型 | 含义 |
| ---- | ---- | ---- |
| `acks` | INT16 | 0=不等待确认；1=等待 leader 确认；-1/`all`=等待 ISR 中 `min.insync.replicas` 确认 |
| `timeout_ms` | INT32 | 等待确认的超时时间 |
| `topic_data` | ARRAY | 每个 topic 的分区与 RecordBatch |

acks 的协议层语义：

- `acks=0`：生产者发完即走，不等待响应，吞吐最高但可能丢失数据；
- `acks=1`：等待 leader 本地追加确认，不保证 follower 已复制；
- `acks=all`：leader 必须收到 ISR 中至少 `min.insync.replicas` 个副本的确认才响应。

当 ISR 不足时，broker 返回 `NOT_ENOUGH_REPLICAS` 错误。注意 `acks` 是在**每条 Produce 请求**中携带的，因此同一生产者可以对不同请求使用不同 acks 策略。

### Fetch 请求与推拉混合语义

`Fetch`（API key 1）是消费者和 follower 副本拉取数据的请求。消费者通过该请求主动“拉”，但通过 `max.wait.ms` 和 `min.bytes` 实现长轮询，从而具备“推”的实时性【论证：推拉混合】。核心字段：

| 字段 | 类型 | 含义 |
| ---- | ---- | ---- |
| `replica_id` | INT32 | 消费者填 -1，follower 副本填自身 broker id |
| `max_wait_ms` | INT32 | 长轮询最大等待时间 |
| `min_bytes` | INT32 | 至少累积多少字节才返回，用于批量优化 |
| `max_bytes` | INT32 | 单次返回最大字节数 |
| `isolation_level` | INT8 | `0=READ_UNCOMMITTED`，`1=READ_COMMITTED` |
| `topics` | ARRAY | 目标分区与 fetch_offset |

`max.wait.ms` 与 `min.bytes` 共同决定响应时机：当数据量达到 `min_bytes` 或等待时间达到 `max_wait.ms` 时 broker 立即返回；否则阻塞等待。这就是 Kafka 消费低延迟与高吞吐兼顾的协议层秘密。

### Fetch 会话与增量 Fetch

在 KIP-227 之前，每个 Fetch 请求都要携带完整的分区列表，分区数多时会带来巨大的请求体开销。KIP-227 引入 **Fetch Session**：

- 首次请求 `session_id=0`，broker 建立会话并返回 `session_id`；
- 后续请求携带 `session_id` 和 `session_epoch`，只需发送**新增/删除/变更的分区**；
- 响应同样只返回有变化的分区数据，空响应体极小。

```text
Fetch Session 状态迁移
1. Full Fetch (session_id=0) → broker 创建 session，返回 session_id
2. Incremental Fetch (session_id=N, epoch++) → 仅携带变更分区
3. Close Fetch (session_epoch=0) → 关闭会话
```

---

## 1.71.4 事务协议

### 事务报文序列

Kafka 事务（KIP-98）通过协调者（Transaction Coordinator）实现两阶段提交，涉及以下 API：

| API Key | 名称 | 作用 |
| ---- | ---- | ---- |
| 22 | `InitProducerId` | 分配/恢复 PID 与 epoch |
| 24 | `AddPartitionsToTxn` | 将目标数据分区注册到当前事务 |
| 25 | `AddOffsetsToTxn` | 将消费者 offset 提交注册到当前事务 |
| 26 | `EndTxn` | 提交或中止事务（`committed=true/false`） |
| 27 | `WriteTxnMarkers` | broker 内部向数据分区写入事务标记 |
| 28 | `TxnOffsetCommit` | 在事务内提交消费位移 |

典型交互序列：

```text
Producer                       Transaction Coordinator
  | ----- InitProducerId -----> |  返回 (PID, epoch)
  |                             |
  | -- AddPartitionsToTxn ----> |  注册分区
  | -- Produce (isTransactional) |  写数据分区（PID/epoch/sequence）
  | -- AddOffsetsToTxn -------> |  注册 offset 消费组
  | -- TxnOffsetCommit -------> |  提交 offset
  | -- EndTxn(commit) --------> |  协调者写 PrepareCommit
  |                             |  -- WriteTxnMarkers(commit) -> 数据分区
  |                             |  -- 协调者写 CompleteCommit
```

### 事务标记写入数据日志的格式

事务的提交或中止不是删除已写数据，而是在每个参与分区的日志中写入一个 **Control Batch**。Control Batch 只有一条控制记录，其 key 格式为：

```text
version: int16 (当前为 0)
type:    int16 (0=ABORT, 1=COMMIT)
```

`READ_COMMITTED` 级别的消费者通过识别这些控制标记，过滤掉 aborted 事务的数据记录。控制批次本身对应用不可见。

### Jepsen 2024-11 对事务协议 unsound 的协议层解读

Jepsen 2024-11 对 Bufstream 0.1.0~0.1.3 的评测不仅发现了 Bufstream 自身的实现缺陷，更指出 **Kafka 事务协议本身存在 unsound 设计**。本项目的第三方证据层已在 [conformance-matrix.md](../../契约语义测试/02-语义矩阵/conformance-matrix.md) 中登记该结论；下面从协议层做解读。

核心问题：协议缺少**客户端请求的顺序约束**和**事务编号**。具体表现为：

1. `EndTxn` 报文只携带 `(transactional_id, producer_id, producer_epoch, committed)`，没有唯一标识“哪一笔事务”；
2. 同一个 producer epoch 内，客户端可能因超时重试、用户手动重试或 `commitTransaction` 超时后调用 `abortTransaction` 而产生**多个在途 `EndTxn` 报文**；
3. 这些 `EndTxn` 报文可能通过不同 TCP 连接到达协调者，网络延迟使旧的 commit/abort 报文在新事务已经开始后才到达；
4. 协调者收到 `EndTxn` 时只能“提交/中止当前正在进行的那个事务”，结果可能出现：
   - **aborted read**：已 abort 的事务部分数据被 commit；
   - **lost writes**：已 commit 的事务被 abort；
   - **torn transaction**：同一事务的部分写入被 commit，另一部分被 abort。

Jepsen 将这一问题追踪为 **KAFKA-17754**，并认为 Kafka 工程师提出的 KIP-890（每笔事务递增 producer epoch）可能修复该问题。Kafka 4.0 起通过 `transaction.version` 特性位启用 KIP-890，每笔事务开始时提升 epoch，使延迟到达的上一事务 `EndTxn` 因 epoch 过旧而被拒绝。

---

## 1.71.5 版本治理

### 消息格式版本与 broker 版本

RecordBatch v2（magic=2）自 Kafka 0.11 起成为默认格式，至今仍是主流。消息格式版本与 broker 版本的关系：

- Broker 可以读取比自身版本更旧的消息格式，但通常会通过升级 inter-broker protocol version 逐步弃用旧格式；
- `log.message.format.version`（或 Kafka 3.0+ 后的 `message.format.version`）控制新写入批次的格式；
- Kafka 4.0 移除了 ZooKeeper，并默认运行在 KRaft 模式，同时 KIP-896 删除了大量旧协议版本。

KIP-896 元数据版本可略提：4.x 的 `metadata.version` 特性位（如 22~30）管理集群级功能开关，`transaction.version` 即其中之一。

### 客户端兼容矩阵

Kafka 4.0 通过 KIP-896 设置了协议 floor：Java 客户端需 2.1+，常见非 Java 客户端需达到以下最低版本【论证：KIP-896 公开兼容性分析】：

| 客户端 | 最低兼容版本 | 说明 |
| ---- | ---- | ---- |
| Apache Kafka Java client | 2.1.0 | KIP-896 基线 |
| librdkafka（C/C++，含 Python/.NET/Go 封装） | 1.8.2 | 2021-10 发布 |
| KafkaJS | 1.15.0 | 2020-11 发布 |
| Sarama（Go） | 1.29.1 | — |
| kafka-python | 2.0.2 | — |
| segmentio/kafka-go | 未官方声明 4.0 兼容 | README 声明测试范围 0.10.1.0~2.7.1；社区 issue 反馈可与 4.0 工作 |

franz-go 等较新的纯 Go 客户端通过主动跟进 KIP-890/KIP-896 已支持 4.x 协议。实际生产升级时，建议先在测试环境验证 `ApiVersions` 握手、`Produce`、`Fetch`、offset commit 与事务路径。

---

## 1.71.6 Kafka 与 MQTT 报文模型对照

本文与 [1.64 MQTT 协议全解析](./01-64-MQTT-5.0协议全解析.md) 形成姊妹篇，二者在报文模型上存在范式差异：

| 维度 | Kafka | MQTT 5.0 |
| ---- | ---- | ---- |
| 拓扑 | broker 中心化，分区是日志 | broker 中心化，topic 是订阅树 |
| 拉取/推送 | 消费者通过 `Fetch` 主动拉 | broker 通过 `PUBLISH` 主动推 |
| 连接状态 | 无会话拉取，offset 由消费者/协调者保存 | CONNECT 建立会话，SUBSCRIBE 维护订阅状态 |
| 报文边界 | 长度前缀二进制帧 | 变长 MQTT 控制报文 |
|  QoS 语义 | acks + ISR 复制，幂等/事务可选 | QoS 0/1/2 在客户端-broker 间定义 |
| 分区/主题 | 分区是物理顺序日志，可并行 | 主题通配符订阅，无天然分区 |

Kafka 的“无会话拉取”使得消费者可以任意重放 offset，而 MQTT 的会话状态绑定在连接上，断连重连需通过 clean start / session expiry 管理。

---

## 1.71.7 抓包分析示例

kcat（原名 kafkacat）已于 2021 年 8 月更名为 kcat，以遵守 Apache 商标政策。下面给出常用命令与 tcpdump 示例。

```bash
# 1. 列出 broker 元数据与 API 版本（ApiVersions 请求可观察）
kcat -b localhost:9092 -L

# 2. 以生产者模式发送一条消息（触发 Produce 请求）
echo "hello wire protocol" | kcat -b localhost:9092 -t events -P

# 3. 以消费者模式拉取一条消息并以 JSON 输出（Fetch 请求 + 解析）
kcat -b localhost:9092 -t events -C -c1 -J

# 4. 使用 tcpdump 抓取 Kafka 端口流量并观察长度前缀帧
tcpdump -i lo -nn -s0 -w kafka.pcap 'tcp port 9092'
# 随后用 Wireshark 打开，过滤 kafka 协议；Request Header 中可见 api_key/api_version/correlation_id
```

`kcat -L` 的输出通常包含 broker 列表、topic 分区、leader、replicas、isr 等信息，本质是客户端发起 `Metadata` 与 `ApiVersions` 请求后的解析结果。若用 Wireshark 查看对应 pcap，可在 Kafka 协议层看到 `ApiVersions Request (key=18)` 与 `Metadata Request (key=3)` 的交互。

---

## 1.71.8 参考来源

### 项目内互链

- 存储与复制内幕：[1.61 Kafka 存储与复制内幕深度解析](./01-61-Kafka存储与复制内幕深度解析.md)
- MQTT 协议全解析：[1.64 MQTT 协议全解析](./01-64-MQTT-5.0协议全解析.md)
- Jepsen 证据登记：[契约语义测试/02-语义矩阵/conformance-matrix.md](../../契约语义测试/02-语义矩阵/conformance-matrix.md)

### 官方参考来源

- [Apache Kafka Protocol Guide](https://kafka.apache.org/protocol) — 协议帧、请求头、所有 API 字段的官方定义
- [Apache Kafka Documentation — Message Format / RecordBatch](https://kafka.apache.org/documentation/#recordbatch) — RecordBatch v2 字段与属性位
- [Apache Kafka Topic Configs — compression.type](https://kafka.apache.org/43/configuration/topic-configs/) — 支持的压缩类型
- [KIP-35: Retrieving protocol version](https://cwiki.apache.org/confluence/display/KAFKA/KIP-35+-+Retrieving+protocol+version) — ApiVersions 机制
- [KIP-227: Introduce Incremental FetchRequests](https://cwiki.apache.org/confluence/display/KAFKA/KIP-227%3A+Introduce+Incremental+FetchRequests+to+Increase+Partition+Scalability) — Fetch Session 与增量 Fetch
- [KIP-896: Remove old client protocol API versions in Kafka 4.0](https://cwiki.apache.org/confluence/display/KAFKA/KIP-896%3A+Remove+old+client+protocol+API+versions+in+Kafka+4.0) — 4.x 协议 floor 与客户端基线
- [KIP-890: Transactions Server-Side Defense](https://cwiki.apache.org/confluence/display/KAFKA/KIP-890%3A+Transactions+Server-Side+Defense) — 每笔事务 epoch bump 修复
- [Jepsen: Bufstream 0.1.0](https://jepsen.io/analyses/bufstream-0.1.0) — 事务协议 unsound 的第三方评测
- [GitHub — edenhill/kcat](https://github.com/edenhill/kcat) — kcat（前 kafkacat）官方仓库，说明更名历史

---

**最后更新**: 2026-11-18
