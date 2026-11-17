# 1.61 Kafka 存储与复制内幕深度解析

> **置信口径**: 协议/规范语义=【定理】（官方规范保证）；架构对比与工程推理=【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Apache Kafka 官方发布信息，核实至 2026-11。关键版本：4.0.0（2025-03-18）、4.2.0（2026-02-17）、4.3.0（2026-05-22）、4.4.0（2026-10-22）。
> **定位声明**: 本文聚焦 Kafka 分区日志的物理存储格式、复制协议、Leader Epoch 截断、KRaft 元数据日志与分层存储实现内幕；KRaft 治理模式与 4.x 队列语义分别见 [1.13 Kafka KRaft模式深度分析](./01-13-Kafka-KRaft模式分析.md)、[1.25 Kafka 4.0 新时代与队列语义分析](./01-25-Kafka-4.0新时代与队列语义分析.md)。

## 目录

- [1.61 Kafka 存储与复制内幕深度解析](#161-kafka-存储与复制内幕深度解析)
  - [目录](#目录)
  - [1.61.1 日志结构存储](#1611-日志结构存储)
    - [Segment / Index / TimeIndex 文件格式](#segment--index--timeindex-文件格式)
    - [内存映射与页缓存依赖](#内存映射与页缓存依赖)
    - [Zero-Copy 传输路径](#zero-copy-传输路径)
  - [1.61.2 复制协议](#1612-复制协议)
    - [LEO 与 HW 语义](#leo-与-hw-语义)
    - [ISR 收缩与 unclean leader election](#isr-收缩与-unclean-leader-election)
    - [KIP-101 / KIP-279 复制一致性修复史](#kip-101--kip-279-复制一致性修复史)
    - [Follower Fetch 协议细节](#follower-fetch-协议细节)
  - [1.61.3 Leader Epoch 与日志截断](#1613-leader-epoch-与日志截断)
    - [Epoch 机制解决的数据丢失场景](#epoch-机制解决的数据丢失场景)
    - [KIP-101 前后对比](#kip-101-前后对比)
  - [1.61.4 KRaft 元数据日志](#1614-kraft-元数据日志)
    - [元数据 topic 存储](#元数据-topic-存储)
    - [快照机制](#快照机制)
    - [与数据日志的差异](#与数据日志的差异)
  - [1.61.5 分层存储内幕](#1615-分层存储内幕)
    - [Remote Log Manager 架构](#remote-log-manager-架构)
    - [Local / Remote 日志边界](#local--remote-日志边界)
    - [KIP-405 语义与延迟权衡](#kip-405-语义与延迟权衡)
  - [1.61.6 存储调优](#1616-存储调优)
    - [Segment 大小与保留策略](#segment-大小与保留策略)
    - [Cleanup Policy 内幕：dedupe 的 key 语义](#cleanup-policy-内幕dedupe-的-key-语义)
    - [刷盘策略与参数影响面](#刷盘策略与参数影响面)
  - [1.61.7 故障场景推演](#1617-故障场景推演)
    - [Broker 磁盘满](#broker-磁盘满)
    - [Broker 磁盘慢](#broker-磁盘慢)
    - [副本落后恢复](#副本落后恢复)
  - [1.61.8 互链与参考来源](#1618-互链与参考来源)

---

## 1.61.1 日志结构存储

### Segment / Index / TimeIndex 文件格式

Kafka 分区日志在物理上是一个追加写的文件序列，每个分区目录下存放一组**segment**文件。当当前活跃 segment 的大小或时间达到阈值时，Kafka 会滚动创建新的 segment。文件名以前一条消息的 offset 命名，固定 20 位数字，例如 `00000000000000000000.log` 表示该 segment 从 offset 0 开始。

```text
/var/kafka-logs/orders-0/
├── 00000000000000000000.log          # 消息数据（RecordBatch 序列）
├── 00000000000000000000.index        # 稀疏 offset → 物理位置索引
├── 00000000000000000000.timeindex    # 稀疏 timestamp → offset 索引
├── 00000000000000035210.log
├── 00000000000000035210.index
├── 00000000000000035210.timeindex
└── leader-epoch-checkpoint           # Leader Epoch 序列文件
```

每个 `.log` 文件由若干 **RecordBatch**（消息批次）组成。RecordBatch 头部包含以下关键字段【定理：Kafka 消息格式规范】：

| 字段 | 长度 | 含义 |
| ---- | ---- | ---- |
| `baseOffset` | 8B | 批次中第一条记录的 offset |
| `batchLength` | 4B | 整个批次的字节长度 |
| `partitionLeaderEpoch` | 4B | 写入该批次时的 Leader Epoch |
| `magic` | 1B | 消息格式版本（v2=2） |
| `crc` | 4B | 批次级校验和 |
| `attributes` | 2B | 压缩类型、事务控制位等 |
| `lastOffsetDelta` | 4B | 批次内最后一条相对 offset |
| `baseTimestamp` | 8B | 批次基准时间戳 |
| `producerId` / `producerEpoch` / `baseSequence` | 8B+2B+4B | 幂等/事务元数据 |

索引文件采用**稀疏索引**：`.index` 每隔 `log.index.interval.bytes`（默认 4KB）记录一条 `(relativeOffset → physicalPosition)` 映射；`.timeindex` 则记录 `(timestamp → relativeOffset)` 映射。查找时先通过文件名定位 segment，再在索引中二分查找，最后从 `.log` 顺序读取。这种设计让 Kafka 在单文件数十 GB 的情况下仍能以 O(log n) 定位消息。

```bash
# 查看某分区的 segment 与索引文件
ls -lh /var/kafka-logs/orders-0/

# 使用 kafka-dump-log 查看 segment 元数据（不解析 payload）
kafka-dump-log.sh --files /var/kafka-logs/orders-0/00000000000000000000.log \
  --print-data-log false
```

### 内存映射与页缓存依赖

Kafka 对 `.log`、`.index`、`.timeindex` 文件使用 `mmap` 进行内存映射，但并不依赖显式 `fsync` 来保证低延迟【论证：Linux 页缓存 + 顺序写设计】。写入时数据先进入页缓存，由操作系统决定何时刷盘；读取时若数据在页缓存则直接命中，否则触发磁盘 IO。

```text
写入路径
Producer → Socket → 网络线程 → 写日志（append to mapped log buffer）
                                     ↓
                              页缓存（Page Cache）
                                     ↓
                              操作系统后台 flush

读取路径
Consumer → Fetch 请求 → 检查 offset 所在 segment
                              ↓
                      索引文件（mmap）定位物理位置
                              ↓
                      .log 文件（mmap）→ sendfile 到网卡
```

这种设计有三个工程后果：

1. **写延迟极低**：顺序写页缓存，绕过了传统 B-Tree 的随机写。
2. **读性能依赖可用内存**：如果工作集超出页缓存，消费延迟会显著上升。
3. **Broker 重启后“热数据”消失**：页缓存清空，前几次读取会触发磁盘 IO，直到缓存重新变暖。

生产环境中通常建议为 Kafka 预留足够 OS 缓存，避免与 JVM 堆争夺内存。典型配置是 JVM 堆 6-8GB，其余物理内存留给页缓存。

### Zero-Copy 传输路径

Kafka 的高吞吐不仅来自日志结构，还来自 **sendfile** 零拷贝路径【定理：Kafka 网络层使用 `FileChannel.transferTo` 或等价的 sendfile 系统调用，将数据从页缓存直接发送到 socket buffer，无需经过用户空间】。

```text
传统拷贝路径（4 次拷贝，4 次上下文切换）
磁盘 → Page Cache → 用户缓冲区 → Socket Buffer → 网卡

Zero-Copy 路径（2 次拷贝，2 次上下文切换）
磁盘 → Page Cache → Socket Buffer → 网卡
```

```java
// Kafka 网络层伪代码：从 log 读取后通过 transferTo 发送
FileChannel logChannel = segment.logChannel();
long position = offsetPosition.position;
long count = fetchSize;
// transferTo 将文件内容直接推入 socket channel
logChannel.transferTo(position, count, socketChannel);
```

当使用 TLS 或压缩转换时，零拷贝会被打断，因为数据必须经过用户空间进行加密/解压缩。因此高吞吐场景通常将 TLS 卸载到负载均衡器，并尽量在 Producer 端完成压缩。

---

## 1.61.2 复制协议

### LEO 与 HW 语义

Kafka 复制协议围绕两个核心水位运行：

- **LEO（Log End Offset）**：副本本地日志的最后一条记录的下一个 offset。Leader 和所有 Follower 各自维护自己的 LEO。
- **HW（High Watermark）**：已提交到 ISR 的最大 offset，消费者只能读取到 HW 之前的消息【定理：Kafka 协议语义】。

```text
副本状态示例（RF=3, ISR={Leader,F1,F2}）

Leader:  [0 1 2 3 4 5 6]   LEO=7   HW=5
F1:      [0 1 2 3 4 5]     LEO=6   HW=5
F2:      [0 1 2 3 4]       LEO=5   HW=5

HW = min(Leader LEO, F1 LEO, F2 LEO) = 5
消费者只能读到 offset ≤ 4 的消息
```

HW 的推进由 Leader 控制：每轮 Follower Fetch 响应会携带 Follower 的 LEO，Leader 计算所有 ISR 副本 LEO 的最小值作为新的 HW，并在下一轮 Fetch 响应中将 HW 传播给 Follower。因此 HW 更新存在**一轮 RPC 延迟**——这正是 KIP-101 要修复的隐患根源。

### ISR 收缩与 unclean leader election

**ISR（In-Sync Replicas）** 是与 Leader 保持同步的副本集合。副本是否“同步”由 `replica.lag.time.max.ms` 判定：若 Follower 在此时间内未向 Leader 发送 Fetch 请求或未能追上 Leader LEO，则被踢出 ISR。

| 配置 | 作用 | 推荐值 |
| ---- | ---- | ---- |
| `replica.lag.time.max.ms` | Follower 最大允许落后时间 | 10000-30000 ms |
| `min.insync.replicas` | `acks=all` 时最少需要确认的副本数 | 2（RF=3 时） |
| `unclean.leader.election.enable` | 是否允许非 ISR 副本成为 Leader | false（默认） |

**unclean leader election 的权衡**：

- 关闭（`false`）：只有 ISR 内副本可晋升 Leader，保证不丢已提交数据，但分区可能不可用直到旧 Leader 恢复或副本追平。
- 开启（`true`）：允许落后副本（非 ISR）成为 Leader，提升可用性，但可能导致已确认消息丢失或日志截断，破坏持久性承诺。

```properties
# server.properties：生产环境推荐配置
replica.lag.time.max.ms=10000
min.insync.replicas=2
unclean.leader.election.enable=false
```

### KIP-101 / KIP-279 复制一致性修复史

Kafka 复制协议在历史上经历过两次关键修复，均与 HW 截断和 Leader 切换有关：

| KIP | 状态 | 引入版本 | 核心修复 |
| ---- | ---- | ---- | ---- |
| **KIP-101** | Accepted | 0.11.0 | 用 Leader Epoch 替代 HW 进行 Follower 日志截断，解决“HW 截断后立即 Leader 选举”导致的数据丢失 |
| **KIP-279** | Accepted | 2.0.0 | 在 `OffsetForLeaderEpoch` 响应中增加 `leader_epoch` 字段，修复快速连续 Leader 切换后的日志发散 |

**KIP-101 解决的场景**：Follower 重启后按本地 HW 截断，然后立即被选举为新 Leader，导致尚未同步到 HW 的已提交消息丢失。引入 Leader Epoch 后，Follower 不再相信自己本地的 HW，而是向 Leader 查询“我所处 Epoch 的合法结束 offset”，只截断 Leader 确实不存在的消息。

**KIP-279 解决的场景**：连续两次快速 Leader 切换后，新 Leader 可能不知道中间某段 Epoch。老协议下 Follower 收到一个不属于自己 Epoch 的 offset 会误判，导致日志发散。KIP-279 让 Leader 返回 `{leader_epoch, end_offset}` 对，Follower 通过多轮 `OffsetForLeaderEpoch` 请求回退到双方共知的最大 Epoch，再完成截断。

### Follower Fetch 协议细节

Follower 通过 **Fetch 请求** 从 Leader 拉取数据，协议流程如下：

```text
1. Follower 发送 FetchRequest(fetchOffset=LEO, currentLeaderEpoch)
2. Leader 返回 FetchResponse(Records, HW, leaderEpoch)
3. Follower 追加到本地日志，更新本地 HW（取 Leader HW 与本地 LEO 较小值）
4. Follower 下一轮 Fetch 携带最新 LEO
5. Leader 根据 ISR 中所有副本 LEO 最小值推进 HW
```

关键请求字段：

```text
FetchRequest
├── replica_id          # Follower 的 broker id
├── max_wait_ms         # 长轮询最大等待时间
├── min_bytes           # 至少返回多少字节才响应（批量优化）
├── max_bytes           # 最大返回字节
├── isolation_level     # READ_UNCOMMITTED / READ_COMMITTED
└── topics
    └── partitions
        ├── partition
        ├── fetch_offset
        ├── log_start_offset
        └── current_leader_epoch   # 用于 epoch 校验
```

当 Follower 发现本地 Leader Epoch 与 Leader 不一致时，会进入 **Truncating** 状态，通过 `OffsetForLeaderEpoch` 协议确定截断点，然后才能回到 **Fetching** 状态。

---

## 1.61.3 Leader Epoch 与日志截断

### Epoch 机制解决的数据丢失场景

Leader Epoch 是一个 32 位单调递增整数，标识某段连续 Leadership 周期。每次该分区发生 Leader 切换，Controller 会分配新的 Epoch，新 Leader 写入的消息都会带上这个 Epoch 编号。

每个副本本地维护一个 **Leader Epoch Sequence File**，记录 `(leader_epoch, start_offset)` 序列：

```text
leader-epoch-checkpoint 示例
v1
3                       # 条目数
0 0                     # epoch 0 从 offset 0 开始
1 15234                 # epoch 1 从 offset 15234 开始
2 28901                 # epoch 2 从 offset 28901 开始
```

**KIP-101 修复的经典数据丢失场景**：

```text
初始：B 是 Leader，A 是 Follower
A fetch m2 后崩溃，本地 HW=0（因为 HW 更新延迟一轮）
A 重启后按 HW=0 截断 → m2 被删除
A 还没追上 B，B 又崩溃 → A 被选举为新 Leader
结果：m2 永久丢失（m2 在 B 上，但 B 已不可用）

KIP-101 修复后：
A 重启后向 B 发送 OffsetForLeaderEpoch(epoch=0)
B 返回 offset=2（epoch 0 的结束位置）
A 发现 2 > 本地 HW=0，不截断 m2
后续 B 恢复后，A/B 日志一致
```

这个机制的本质是：Follower 不再用本地 HW 作为截断依据，而是用 Leader 的 Epoch 历史来决定自己哪些消息是“合法存在”的。

### KIP-101 前后对比

| 维度 | KIP-101 之前 | KIP-101 之后 |
| ---- | ---- | ---- |
| 截断依据 | 本地 HW | Leader Epoch + OffsetForLeaderEpoch |
| 数据丢失风险 | 崩溃-重启-立即选举序列可丢已提交消息 | 只截断 Leader 确认不存在的消息 |
| 协议交互 | 无额外 RPC | 增加 OffsetForLeaderEpoch 请求 |
| 持久性保证 | 依赖 HW 持久化时机 | 依赖 Epoch 序列文件持久化 |

KIP-279 进一步补全：在 KIP-101 的 `OffsetForLeaderEpochResponse` 中新增 `leader_epoch` 字段，使 Follower 能识别返回的 offset 属于哪个 Epoch，从而处理“Leader 不知道 Follower 请求的 Epoch”这一边界情况。

---

## 1.61.4 KRaft 元数据日志

### 元数据 topic 存储

KRaft 模式下，Kafka 使用一个内部主题 `__cluster_metadata` 存储所有集群元数据。该主题只有 1 个分区（partition 0），由 Controller Quorum 共同维护。每条元数据变更（如创建 Topic、分区重分配、Broker 注册、配置更新）都被作为一条记录追加到这个元数据日志中。

```text
__cluster_metadata-0/
├── 00000000000000000000.log
├── 00000000000000000000.index
├── 00000000000000000000.timeindex
├── 00000000000001024567.log
└── ...
```

与数据日志不同，元数据日志：

- 记录的是**状态机命令**而非业务消息；
- 通过 Raft 协议在 Quorum 间复制，保证线性一致性；
- 写入路径经过 Controller Leader，由 Leader 向 Follower 发送 AppendEntries；
- 读操作由每个 Broker 本地维护的元数据缓存提供，不直接读日志。

### 快照机制

KRaft 会定期生成**元数据快照**（snapshot），将某一时刻的完整元数据状态持久化为一个快照文件。快照的作用是加速恢复：新 Controller 启动或 Follower 落后太多时，可以直接加载最新快照，再重放快照之后的少量日志条目，无需从头读取整个元数据日志。

```properties
# controller.properties：快照相关配置
metadata.log.segment.bytes=1073741824        # 1GB
metadata.log.retention.ms=604800000          # 7天
metadata.log.max.snapshot.interval.ms=3600000 # 每小时最多生成一次快照
```

快照与日志的关系：

```text
元数据状态恢复
├── 加载最新快照（offset=N 时的完整状态）
├── 从 offset=N+1 开始重放日志条目
└── 恢复到当前提交状态
```

### 与数据日志的差异

| 维度 | 数据日志（业务 Topic） | 元数据日志（`__cluster_metadata`） |
| ---- | ---- | ---- |
| 存储内容 | 业务 RecordBatch | Controller 状态变更记录 |
| 复制协议 | ISR + HW 复制协议 | Raft Quorum 共识 |
| 分区数 | 用户定义，可多个 | 固定 1 个分区 |
| 一致性模型 | 最终一致（acks 可调） | 线性一致（Raft） |
| 快照 | 无（由分层存储/Rolling 管理） | 有定期快照 |
| 读写主体 | Producer / Consumer | Controller / Broker 元数据缓存 |

> 深入阅读：[1.13 Kafka KRaft模式深度分析](./01-13-Kafka-KRaft模式分析.md)

---

## 1.61.5 分层存储内幕

### Remote Log Manager 架构

Kafka 分层存储（Tiered Storage，KIP-405）将日志分为本地热层和远程冷层。核心组件是 **RemoteLogManager（RLM）**，它运行在 Broker 内部，负责：

1. **Leader RLM Task**：将已滚动、且 last offset < LSO 的 segment 复制到远程存储；
2. **Follower RLM Task**：跟踪远程 segment 元数据，必要时从远程层读取；
3. **元数据管理**：通过 `RemoteLogMetadataManager`（默认实现使用内部 topic `__remote_log_metadata`）记录远程 segment 信息；
4. **删除过期远程 segment**：根据远程保留策略清理对象存储中的数据。

```text
┌─────────────────────────────────────────────────────────────┐
│                        Kafka Broker                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐ │
│  │ Local Log   │◄──►│ RemoteLog   │◄──►│ RemoteStorage   │ │
│  │ (.log/.idx) │    │ Manager     │    │ Manager (S3/HDFS)│ │
│  └──────┬──────┘    └──────┬──────┘    └─────────────────┘ │
│         │                  │                                │
│         │         ┌────────┴────────┐                       │
│         │         │ RemoteLogMetadata │                     │
│         │         │ Manager (RLMM)    │                     │
│         │         │ __remote_log_metadata                  │
│         │         └───────────────────┘                     │
└─────────┴───────────────────────────────────────────────────┘
                  │
                  ▼
           Object Storage (S3 / GCS / Azure Blob)
```

```properties
# server.properties：分层存储基础配置
remote.log.storage.system.enable=true
remote.log.storage.manager.class.name=org.apache.kafka.rlm.storage.s3.S3RemoteStorageManager
remote.log.metadata.manager.listener.name=PLAINTEXT
remote.log.manager.task.interval.ms=30000
remote.log.manager.thread.pool.size=10
```

### Local / Remote 日志边界

分层存储引入了几个新的 offset 边界概念：

| 概念 | 符号 | 含义 |
| ---- | ---- | ---- |
| Local Log Start Offset | LSO_local | 本地日志起始 offset |
| Local Log End Offset | LEO_local | 本地日志结束 offset |
| Remote Log End Offset | RLEO | 已上传到远程存储的最大 offset |
| Earliest Local Offset | ELO | 本地最早可用 offset（ followers 从此开始复制） |

约束关系：`LEO_local ≥ RLEO ≥ LSO_local`，且 `ELO = LSO_local`（默认策略下）。

当 Follower 请求的 offset 已不在 Leader 本地时，Leader 返回 `OFFSET_MOVED_TO_TIERED_STORAGE` 错误。Follower 随后通过 `ListOffsets(EARLIEST_LOCAL_TIMESTAMP)` 获取 ELO，并进入 **BuildingRemoteLogAuxState** 状态，从远程存储重建 Leader Epoch 和 Producer ID 快照等辅助状态，然后才继续 Fetch。

### KIP-405 语义与延迟权衡

KIP-405 已于 Kafka 3.9 进入 production-ready 状态【定理：KIP-405 官方状态】，并在 Kafka 4.x 持续成熟。其设计目标不是替代本地存储，而是：

- 让长期保留（月级）经济可行；
- 让 Broker 扩缩容/故障恢复时少复制大量冷数据；
- 对 Producer 和 Consumer 保持透明。

**延迟权衡表**：

| 读取类型 | 数据位置 | 典型延迟 | 说明 |
| ---- | ---- | ---- | ---- |
| 尾部消费 | 本地 Page Cache | 1-10 ms | 与未开启分层存储时相同 |
| 追赶消费（近期数据） | 本地磁盘 | 5-50 ms | 受磁盘吞吐限制 |
| 历史回放（冷数据） | 对象存储 | 数十 ms ~ 数百 ms | 受网络与对象存储延迟限制 |

```properties
# topic-level：开启分层存储
kafka-configs.sh --bootstrap-server localhost:9092 \
  --entity-type topics --entity-name events \
  --alter --add-config \
  remote.storage.enable=true,local.retention.ms=604800000,retention.ms=2592000000
```

生产注意：

- 不支持 `cleanup.policy=compact` 与分层存储同时启用；
- 不支持 JBOD 与分层存储同时启用；
- 远程元数据 topic 本身也需要足够的副本与保留配置。

---

## 1.61.6 存储调优

### Segment 大小与保留策略

Segment 大小和保留策略直接影响磁盘空间、恢复时间和查询效率。相关核心参数如下：

```properties
# server.properties 或 topic-level 配置
log.segment.bytes=1073741824            # 单个 segment 文件大小上限，默认 1GB
log.roll.hours=168                      # 按时间强制滚动 segment，默认 7 天
log.retention.hours=168                 # 按时间保留，默认 7 天
log.retention.bytes=1073741824          # 按分区总大小保留（与 retention.hours 同时生效）
log.cleanup.policy=delete               # delete 或 compact
log.segment.delete.delay.ms=60000       # segment 删除前延迟，默认 1 分钟
```

**参数影响面与调优场景表**：

| 参数 | 影响面 | 调大场景 | 调小场景 |
| ---- | ---- | ---- | ---- |
| `log.segment.bytes` | 单个文件大小、恢复时间、索引粒度 | 高吞吐、大消息、长期保留 | 需要更频繁滚动、更快删除 |
| `log.retention.hours` | 可回溯时长、磁盘占用 | 合规审计、事件溯源 | 日志/埋点、磁盘紧张 |
| `log.retention.bytes` | 分区最大占用 | 磁盘受限、按容量计费 | 需要保证最低保留时长 |
| `log.roll.hours` | segment 滚动频率 | 低吞吐但需要按时间归档 | 高吞吐、大文件更高效 |

### Cleanup Policy 内幕：dedupe 的 key 语义

`cleanup.policy=compact` 不是简单删除，而是**按 key 保留最新值**的日志压缩。其语义可概括为：对同一个 key，只保留 offset 最大的那条记录；key 为 `null` 的记录不会被压缩（因为没有去重键）。

```text
压缩前：            压缩后（按 key 保留最新）
offset key value   offset key value
0      k1  v1      2      k1  v3
1      k2  v2  ->  4      k2  v4
2      k1  v3
3      k2  v2
4      k2  v4
```

压缩触发条件：

1. segment 中“脏记录”比例（未被压缩的 key）超过 `min.cleanable.dirty.ratio`（默认 0.5）；
2. segment 已滚动为不活跃状态；
3. 压缩线程在后台执行，不会阻塞写入。

```properties
# compact topic 配置示例
log.cleanup.policy=compact
min.cleanable.dirty.ratio=0.5
delete.retention.ms=86400000            # 被压缩删除记录的 tombstone 保留时间
segment.ms=604800000                    # 强制滚动，避免 segment 永远不压缩
```

> ⚠️ 不要把需要完整审计的 topic 设置为 compact，因为旧值会被删除。compact 适合状态快照、KTable changelog 等“最新状态即真相”的场景。

### 刷盘策略与参数影响面

Kafka 默认依赖操作系统刷盘，但可以通过参数调整刷盘频率和可靠性：

```properties
# 刷盘策略
log.flush.interval.messages=10000       # 每 N 条消息强制刷盘（默认不启用）
log.flush.interval.ms=1000              # 每 N 毫秒强制刷盘（默认不启用）
log.flush.scheduler.interval.ms=3000    # 刷盘调度器检查间隔
```

| 参数 | 影响面 | 推荐场景 |
| ---- | ---- | ---- |
| `log.flush.interval.messages` | 强制 fsync 的消息数阈值 | 金融级强持久，但会显著增加写入延迟 |
| `log.flush.interval.ms` | 强制 fsync 的时间阈值 | 需要 bounded 数据丢失窗口 |
| `log.flush.scheduler.interval.ms` | 刷盘调度频率 | 一般保持默认 |

实践建议：

- 大多数场景**不需要**设置 `log.flush.interval.*`，依赖 OS 刷盘和副本机制即可；
- 如果设置刷盘阈值，通常与 `acks=all` + `min.insync.replicas=2` 组合使用；
- 更常见的瓶颈是网络、页缓存命中率和磁盘 IO 吞吐，而非刷盘频率。

---

## 1.61.7 故障场景推演

### Broker 磁盘满

当 Broker 磁盘使用率达到上限（默认 95% 由 `log.segment.bytes` + OS 决定，Kafka 无内置硬阈值），该 Broker 上的分区会无法继续追加消息。Controller 会将受影响分区的 Leader 切换到其他 Broker（如果可用副本存在）。

| 阶段 | HW/ISR 行为 | 观察指标 | 处置 |
| ---- | ---- | ---- | ---- |
| 磁盘接近满 | 写入延迟增加，刷盘竞争 | `log_dir_capacity` / OS disk usage | 扩容或清理旧 segment |
| 磁盘写满 | 该 Broker 分区停止追加；Leader 切换 | `UnderReplicatedPartitions` 上升 | 紧急扩容磁盘或迁移分区 |
| 清理/扩容后 | Follower 从 Leader 追赶，HW 逐步恢复 | `ReplicaFetcherManager` lag | 监控直到 ISR 恢复完整 |

```bash
# 监控磁盘使用率（告警阈值建议 80%，危险阈值 90%）
df -h /var/kafka-logs

# 查看哪些分区 under-replicated
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic orders
```

### Broker 磁盘慢

磁盘慢（IOPS 抖动、RAID 重建、云盘突发积分耗尽）会导致 Follower Fetch 延迟增加，超出 `replica.lag.time.max.ms` 后被踢出 ISR。

| 阶段 | HW/ISR 行为 | 影响 | 处置 |
| ---- | ---- | ---- | ---- |
| 轻微变慢 | Fetch 延迟增加，但仍在 ISR 内 | 复制延迟上升 | 定位磁盘问题 |
| 持续落后 | Follower 被踢出 ISR，HW 可能停滞 | `IsrShrinksPerSec` 增加 | 隔离慢盘 Broker |
| 恢复后 | Follower 重新加入 ISR，HW 推进 | `IsrExpandsPerSec` | 验证复制追上 |

```bash
# 查看 ISR 变化
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group __consumer_offsets

# JMX 指标示例
kafka.server:type=ReplicaManager,name=IsrShrinksPerSec
kafka.server:type=ReplicaManager,name=IsrExpandsPerSec
```

### 副本落后恢复

当 Follower 因网络分区、GC 停顿或磁盘问题长时间落后，恢复后需要从 Leader 追赶。若分层存储开启，且落后数据已被卸载到远程，Follower 会走 `OFFSET_MOVED_TO_TIERED_STORAGE` 路径，从远程层重建辅助状态后再追本地数据。

| 场景 | 本地数据状态 | 恢复路径 | 时间特征 |
| ---- | ---- | ---- | ---- |
| 小幅落后 | 本地 segment 仍存在 | 直接从 Leader Fetch 追赶 | 分钟级 |
| 大幅落后 | 本地 segment 已删除 | Leader 返回 OMTS，Follower 从远程重建 | 数十分钟级 |
| 新副本 | 无本地数据 | 从 ELO 开始，可能完全走远程层 | 取决于远程元数据同步 |

```text
分层存储下 Follower 恢复流程
1. Follower fetch offset=X，Leader 本地已无该 offset
2. Leader 返回 OFFSET_MOVED_TO_TIERED_STORAGE
3. Follower ListOffset(EARLIEST_LOCAL_TIMESTAMP) 获取 ELO
4. Follower 进入 BuildingRemoteLogAuxState
5. 从 RemoteLogMetadataManager 获取远程 segment 列表
6. 下载 Leader Epoch / Producer Snapshot 等辅助状态
7. 状态重建完成后回到 Fetching，从 ELO 开始追 Leader
```

---

## 1.61.8 互链与参考来源

### 项目内互链

- KRaft 治理与 Controller Quorum 细节：[1.13 Kafka KRaft模式深度分析](./01-13-Kafka-KRaft模式分析.md)
- Kafka 4.x 队列语义与版本演进：[1.25 Kafka 4.0 新时代与队列语义分析](./01-25-Kafka-4.0新时代与队列语义分析.md)
- 全局概念一致性基线：[1.58 全局核心概念卡片总表](./01-58-全局核心概念卡片总表.md)
- 存储设计原理与选型论证：[2.28 消息存储设计](../02-场景驱动架构设计/02-28-消息存储设计.md)
- 性能调优落地操作：[3.29 性能调优手册](../03-架构与运维实践/03-29-性能调优手册.md)
- 存储配置模板：`../config-templates/storage-config.properties`

### 官方参考来源

- [Apache Kafka Documentation — Replication](https://kafka.apache.org/documentation/#replication)
- [KIP-101: Alter Replication Protocol to use Leader Epoch rather than High Watermark for Truncation](https://cwiki.apache.org/confluence/display/KAFKA/KIP-101+-+Alter+Replication+Protocol+to+use+Leader+Epoch+rather+than+High+Watermark+for+Truncation) — Accepted，引入 Kafka 0.11.0
- [KIP-279: Fix log divergence between leader and follower after fast leader fail over](https://cwiki.apache.org/confluence/display/KAFKA/KIP-279%3A+Fix+log+divergence+between+leader+and+follower+after+fast+leader+fail+over) — Accepted，引入 Kafka 2.0.0
- [KIP-405: Kafka Tiered Storage](https://cwiki.apache.org/confluence/display/KAFKA/KIP-405%3A+Kafka+Tiered+Storage) — Accepted，Kafka 3.9 起 production-ready
- [Apache Kafka 4.0.0 Release Announcement](https://kafka.apache.org/blog/2025/03/18/apache-kafka-4.0.0-release-announcement/)
- [Apache Kafka 4.2.0 Release Announcement](https://kafka.apache.org/blog/2026/02/17/apache-kafka-4.2.0-release-announcement/)
- [Apache Kafka 4.3.0 Release Announcement](https://kafka.apache.org/blog/2026/05/22/apache-kafka-4.3.0-release-announcement/)
- [Apache Kafka 4.4.0 Release Announcement](https://kafka.apache.org/blog/2026/10/22/apache-kafka-4.4.0-release-announcement/)
- [Kafka KRaft Metadata Storage](https://kafka.apache.org/documentation/#kraft_metadata)

---

**最后更新**: 2026-11-18
