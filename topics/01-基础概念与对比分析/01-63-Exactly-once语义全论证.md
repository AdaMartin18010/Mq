# 1.63 Exactly-once 语义全论证

> **置信口径**: 协议/规范语义 =【定理】（官方规范保证）；架构对比与工程推理 =【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Apache Kafka、Apache Pulsar、RabbitMQ、NATS、MQTT、Redis 官方发布信息及 Jepsen 公开评测，核实至 2026-11。
> **定位声明**: 本文是 `01-基础概念与对比分析` 系列深度旗舰篇，对 exactly-once 语义做端到端论证；具体模式落地见 [2.47 企业集成模式与事务消息模式](../02-场景驱动架构设计/02-47-企业集成模式与事务消息模式.md)，形式化方法框架见 [1.4 形式化证明框架](01-04-形式化证明框架.md)，概念速查见 [1.58 全局核心概念卡片总表](01-58-全局核心概念卡片总表.md)，Kafka 4.0 队列语义与幂等生产者演进见 [1.25 Kafka 4.0 新时代与队列语义分析](01-25-Kafka-4.0新时代与队列语义分析.md)。

## 目录

- [1.63 Exactly-once 语义全论证](#163-exactly-once-语义全论证)
  - [目录](#目录)
  - [1.63.1 语义基础：交付语义的精确定义](#1631-语义基础交付语义的精确定义)
    - [时序图刻画](#时序图刻画)
    - [Two Generals 不可能性与端到端 exactly-once 的约束](#two-generals-不可能性与端到端-exactly-once-的约束)
  - [1.63.2 幂等生产者机制](#1632-幂等生产者机制)
    - [PID 与 Sequence Number](#pid-与-sequence-number)
    - [Epoch Bump 与会话恢复](#epoch-bump-与会话恢复)
    - [幂等生产者与事务的关系](#幂等生产者与事务的关系)
  - [1.63.3 Kafka 事务](#1633-kafka-事务)
    - [事务协调器与 TCC 两阶段提交](#事务协调器与-tcc-两阶段提交)
    - [transactional.id 与 Fencing 机制](#transactionalid-与-fencing-机制)
    - [Consume-Transform-Produce 全链路](#consume-transform-produce-全链路)
  - [1.63.4 流处理 exactly-once](#1634-流处理-exactly-once)
    - [Kafka Streams EOS v1→v2 演进](#kafka-streams-eos-v1v2-演进)
    - [Flink Checkpoint 与两阶段提交](#flink-checkpoint-与两阶段提交)
    - [Pulsar 事务现状](#pulsar-事务现状)
  - [1.63.5 外部系统桥接](#1635-外部系统桥接)
    - [Outbox/Inbox 模式的形式化刻画](#outboxinbox-模式的形式化刻画)
    - [Saga 补偿的最终一致语义](#saga-补偿的最终一致语义)
    - [Change Data Capture 路径](#change-data-capture-路径)
  - [1.63.6 语义边界：Exactly-once 不等于“应用不重复处理”](#1636-语义边界exactly-once-不等于应用不重复处理)
    - [Ack 点与副作用点分析](#ack-点与副作用点分析)
    - [Side Effect 去重的责任划分](#side-effect-去重的责任划分)
  - [1.63.7 六系统语义能力对照总表与选型决策](#1637-六系统语义能力对照总表与选型决策)
  - [1.63.8 真实形式化资产与引用纪律](#1638-真实形式化资产与引用纪律)
  - [1.63.9 参考来源](#1639-参考来源)

---

## 1.63.1 语义基础：交付语义的精确定义

消息系统的交付语义（Delivery Semantics）描述的是：在存在网络分区、节点故障、客户端重启等故障场景下，系统对“一条消息是否会被投递给消费端”所做的承诺。业界通常归纳为三类：at-most-once、at-least-once、exactly-once。本文在时序语义层面对三者做精确刻画，并给出端到端 exactly-once 不可能性的理论约束。

### 时序图刻画

设消息为 `m`，生产者为 `P`，消息代理为 `B`，消费者为 `C`。一次完整投递可抽象为三个事件：

- `send(m)`：生产者发出消息；
- `deliver(m)`：代理将消息投递给消费者；
- `process(m)`：消费者完成业务处理并确认。

【定理】三种交付语义的时序约束可定义如下：

| 交付语义 | 形式化约束 | 时序语义 | 对应用承诺 |
| --- | --- | --- | --- |
| **at-most-once** | `∀m, count(deliver(m) ∨ process(m)) ≤ 1` | 消息最多进入消费端一次，失败后不重试 | 可能丢失，不会重复 |
| **at-least-once** | `∀m, if send(m) succeeds at B then ∃t, deliver(m)@t` | 消息成功入队后至少被投递一次，失败则重试 | 不会丢失，可能重复 |
| **exactly-once** | `at-least-once(m) ∧ at-most-once(m)` | 消息成功入队后且仅被有效处理一次 | 不丢且不重（在系统语义边界内） |

上述表格对语义做了集合论层面的定义，是后续所有工程实现的逻辑基线。需要强调的是，这里的 `process(m)` 是消息系统可观测到的“确认完成”事件，而非应用业务层的副作用；当讨论“端到端 exactly-once”时，必须将应用副作用纳入同一个形式化框架（见 1.63.6）。

三种语义的典型交互时序如下：

```text
# at-most-once：发送即完成，无确认、无重试
P ->> B: send(m)
B ->> C: deliver(m)
Note over C: 处理或丢失，P 不感知

# at-least-once：必须收到 ACK，否则重试
P ->> B: send(m)
B ->> P: ack(m)
B ->> C: deliver(m)
C ->> B: ack(m)
alt ACK 丢失
    P ->> B: send(m) [retry]
end

# exactly-once：在 at-least-once 基础上引入去重/事务边界
P ->> B: send(m) within txn T
B ->> P: ack(m)
B ->> C: deliver(m) after T commit
C ->> B: ack(m)
Note over B: 通过 PID/SeqNo 或事务标记去重
```

【定理】在协议层，at-most-once 等价于“无确认义务的一次性投递”；at-least-once 等价于“带确认与重试的投递”；exactly-once 等价于“at-least-once 投递 + 去重机制 + 原子提交边界”三者的合取。该刻画源自消息系统协议语义，并与 [1.4 形式化证明框架](01-04-形式化证明框架.md) 中 1.4.5 节的语义对比表一致。

### Two Generals 不可能性与端到端 exactly-once 的约束

【论证】Two Generals Problem（又称 coordinated attack problem）是分布式系统理论中的经典不可能性结果：两个进程通过不可靠信道试图达成共同行动协议，不存在任何有限消息轮次的确定性协议能保证双方同时知道对方已同意。其证明核心在于“确认的确认”无限回归——无论多少轮 ACK，最后一轮 ACK 的发送者都无法确认对方已收到该 ACK。

该结果对消息系统的直接约束是：

1. **网络边界上不存在“绝对恰好一次投递”**。如果生产者在未收到 ACK 时超时重试，则存在同一条消息被写入两次的可能；如果生产者不重试，则存在消息丢失的可能。任何在不可靠网络上的有限协议都无法同时消除这两种可能。
2. **消息系统能提供的 exactly-once 是“系统内部语义”**：通过去重键、事务标记、幂等写等机制，保证同一条消息在代理内部不被重复记录或重复投递。但一旦消息离开代理边界进入应用，应用必须自行保证副作用幂等。
3. **端到端 exactly-once 的充要条件是**：系统内 exactly-once + 应用处理幂等 + 副作用可撤销或可去重。即：

```text
End-to-End EOS = Broker EOS ∧ Idempotent Consumer ∧ Idempotent/Deduplicated Side Effects
```

【论证】因此，所有宣称“端到端 exactly-once”的产品或方案，本质上都把“恰好一次”分解为两个责任域：消息系统负责“不重复入队/投递”，应用负责“不重复生效”。任何一方缺失，端到端语义即被破坏。该结论也是 [1.58 全局核心概念卡片总表](01-58-全局核心概念卡片总表.md) 将 `exactly-once` 标注为“需端到端幂等+事务”而非“消息不重复到达应用”的根本原因。

---

## 1.63.2 幂等生产者机制

Kafka 的幂等生产者（Idempotent Producer）是实现 exactly-once 的底层基石。它在不引入事务的情况下，为单会话、单分区写提供了“去重”能力。

### PID 与 Sequence Number

【定理】Kafka 幂等生产者的核心机制为：

- **Producer ID（PID）**：每个启用幂等的生产者在初始化时向 Broker 申请一个全局唯一的 `PID`（64 位整数），标识一个逻辑生产者会话。
- **Sequence Number（SeqNo）**：每个 `<PID, TopicPartition>` 对维护一个单调递增的序列号。Broker 按 `<PID, epoch, SeqNo>` 三元组对入队消息去重。
- **Broker 端去重表**：Broker 在每个分区 Leader 上维护最近 5 个 Producer ID 的 SeqNo 窗口，重复 SeqNo 被丢弃。

启用幂等生产者的配置：

```properties
# Kafka 生产者幂等配置（单会话单分区 exactly-once 写）
enable.idempotence=true
acks=all
retries=2147483647
max.in.flight.requests.per.connection=5
```

【定理】在 `enable.idempotence=true` 且 `acks=all` 时，Kafka 保证：对于同一个 `<PID, epoch>`，若生产者因网络抖动重试 `send()`，Broker 不会导致消息重复落盘，也不会破坏同分区消息顺序。该保证的边界是：

- 仅作用于**单个生产者会话**（PID 生命周期内）；
- 仅作用于**单个分区**；
- 不保证跨分区原子写，也不保证消费位移提交与生产写的原子性。

### Epoch Bump 与会话恢复

当幂等生产者遭遇不可恢复错误（如 `OutOfOrderSequenceException`、`UnknownProducerIdException`）或应用重启时，会触发 `initProducerId()` 重新向事务协调器注册。此时：

- 若未配置 `transactional.id`，Broker 会分配一个**全新 PID**，旧 PID 的幂等状态被丢弃；
- 若配置了 `transactional.id`，协调器会执行 **epoch bump**，保留 `transactional.id` 但递增 `producer epoch`。

```text
# epoch bump 示意
producer session: transactional.id = "payments-producer-1"
                 PID = 42, epoch = 0  ->  正常生产
                 crash / fenced      ->  epoch = 1
                 旧 epoch 的写被 fence，新 epoch 的写才生效
```

【论证】`producer epoch` 是 Kafka fencing 旧会话、防止僵尸写（zombie writes）的关键。当新的生产者实例以相同 `transactional.id` 启动时，旧 epoch 的任何后续写（如延迟到达的网络包）都会被 Broker 拒绝，从而避免“幽灵写入”。该机制在 KIP-98 中定义，并在 KIP-890 中通过服务端增强进一步加固。

### 幂等生产者与事务的关系

| 能力 | 幂等生产者 | Kafka 事务 |
| --- | --- | --- |
| 去重粒度 | 单会话、单分区 | 跨分区、跨生产/消费位移 |
| 原子性 | 无 | 多分区写原子提交/回滚 |
| 配置开关 | `enable.idempotence=true` | `transactional.id` + 事务 API |
| 依赖关系 | 事务生产者**必须**启用幂等 | 幂等生产者**不必须**事务 |
| 适用场景 | 单分区无状态写 | consume-transform-produce、EOS |

【论证】事务生产者内部复用 PID/SeqNo 机制完成去重，因此 `enable.idempotence=true` 是事务的前置条件。但幂等生产者本身不提供事务边界，不能解决“消费位移提交与生产结果不一致”的问题。这是 1.63.3 节引入 Kafka 事务的根本原因。

---

## 1.63.3 Kafka 事务

Kafka 事务（KIP-98）在幂等生产者之上增加了两阶段提交协议，实现跨分区写、以及消费位移提交与生产写的原子性。

### 事务协调器与 TCC 两阶段提交

Kafka 事务的参与者：

- **Transaction Coordinator（TC）**：每个 `transactional.id` 映射到一个 Broker 上的 TC，负责维护事务状态（Ongoing / PrepareCommit / CompleteCommit / CompleteAbort）。
- **Transaction Log**：TC 将事务元数据写入内部 `__transaction_state` 主题，用于故障恢复。
- **分区 Leader**：接收事务消息并写入分区日志，但在事务提交前对消费者不可见（`read_committed` 隔离级别）。

事务执行流程（TCC 两阶段）：

```text
Phase 1: Try / 准备阶段
  1. producer.initTransactions()      # 注册 PID/epoch
  2. producer.beginTransaction()      # 标记事务开始
  3. producer.send(record)            # 写入目标分区（带事务标记）
  4. producer.sendOffsetsToTransaction(consumer.position(), consumerGroupId)
                                     # 将消费位移也纳入事务

Phase 2: Commit / 提交阶段
  5. producer.commitTransaction()     # TC 写入 PrepareCommit
  6. TC 向所有相关分区 Leader 发送 CommitMarker
  7. 分区 Leader 将 CommitMarker 追加到日志
  8. TC 写入 CompleteCommit

Abort 路径：producer.abortTransaction() -> TC 写入 PrepareAbort -> AbortMarker -> CompleteAbort
```

对应 Java 代码骨架：

```java
Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "payments-producer-1");
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
props.put(ProducerConfig.ACKS_CONFIG, "all");

KafkaProducer<String, String> producer = new KafkaProducer<>(props);
producer.initTransactions();

try {
    producer.beginTransaction();
    producer.send(new ProducerRecord<>("output-topic", key, value));
    producer.sendOffsetsToTransaction(
        consumer.position(consumer.assignment()),
        consumer.groupMetadata()
    );
    producer.commitTransaction();
} catch (Exception e) {
    producer.abortTransaction();
    throw e;
}
```

【论证】上述 TCC（Try-Confirm-Cancel）语义中，Try 阶段完成所有副作用的准备，Confirm/Cancel 阶段由 TC 统一决定。Kafka 通过 `CommitMarker` / `AbortMarker` 在分区日志中显式标记事务边界，`read_committed` 消费者据此过滤未提交或已中止的消息。

### transactional.id 与 Fencing 机制

`transactional.id` 是 Kafka 事务中用于识别同一逻辑生产者的全局标识。其核心作用：

1. **状态持久化**：TC 将 `<transactional.id, PID, epoch>` 持久化到 `__transaction_state`，使生产者在重启后仍能恢复同一身份。
2. **Fencing 旧实例**：当新的生产者以相同 `transactional.id` 初始化时，TC 将 epoch 递增，任何持有旧 epoch 的生产者后续写都会被拒绝。
3. **分区映射稳定性**：TC 通过 `transactional.id` 的哈希确定所在 Broker，保证同一生产者的事务协调器不变。

```text
# fencing 场景
Instance A: transactional.id=tx-1, PID=42, epoch=0  [因 GC 暂停]
Instance B: transactional.id=tx-1, PID=42, epoch=1  [新启动]

Instance A 恢复后继续使用 epoch=0 发送
Broker TC: InvalidProducerEpochException -> 拒绝旧实例写
```

【论证】`transactional.id` 的 fencing 是 Kafka 防止“僵尸实例”破坏 exactly-once 的关键。但如果 `transactional.id` 配置随机化或频繁变化，则无法发挥 fencing 作用；若多个应用实例共享同一 `transactional.id`，则会导致彼此互相 fencing，引发事务异常。

### Consume-Transform-Produce 全链路

这是 Kafka 事务最典型的应用场景：从一个主题读取、转换、写入另一个主题，并把消费位移提交与生产写原子化。

```text
[Source Topic] --(consumer read)--> [Transform Logic] --(producer send)--> [Sink Topic]
                                         |
                                         v
                              [consumer offset commit]
                              (通过 sendOffsetsToTransaction 纳入事务)
```

链路保证：

- 若事务提交成功：输出消息可见，且输入位移也被提交；
- 若事务中止：输出消息不可见（AbortMarker），输入位移回滚，下游可重新消费输入。

【论证】该链路实现了“处理一次且仅一次”的系统级语义，但前提是：

1. transform 逻辑本身无副作用或可幂等；
2. 消费者隔离级别设为 `read_committed`；
3. 生产者启用幂等并配置稳定的 `transactional.id`。

---

## 1.63.4 流处理 exactly-once

流处理引擎在 Kafka 事务之上，进一步将“状态快照”与“输出提交”绑定，实现端到端 exactly-once。

### Kafka Streams EOS v1→v2 演进

Kafka Streams 的 exactly-once 语义经历了两个主要版本：

| 版本 | 配置值 | 核心 KIP | 关键变化 | 已知限制 |
| --- | --- | --- | --- | --- |
| **EOS v1** | `exactly_once` | KIP-129 | 每个任务一个 `transactional.id` | 事务开销大，任务数多时控制记录爆炸 |
| **EOS v2** | `exactly_once_v2` | KIP-447 | 每个 Stream Thread 一个 `transactional.id`，用 consumer group epoch 做 fencing | 显著降低控制记录，推荐生产使用 |
| **未来** | — | KIP-890 | 服务端事务防御，修复事务状态漂移与悬挂事务 | Kafka 3.8+ 引入 `transaction.version=2`，4.0+ 可启用 |

【论证】KIP-129（Kafka 0.11.0，2017）首次在 Kafka Streams 中实现 EOS，其设计为每个流任务绑定一个 `transactional.id`。当拓扑任务数很多时，每个 commit interval 会产生大量事务控制批次，显著影响吞吐与延迟。KIP-447（Kafka 2.5+）将其改进为每个 Stream Thread 一个 `transactional.id`，利用消费者组 epoch 来 fence 旧线程，从而将事务开销降低一个数量级。KIP-890（Kafka 3.8/4.0）进一步在 Broker 端增强事务协议，防止乱序/延迟的 `AddPartitionsToTxn` 或 `EndTxn` 请求导致悬挂事务或 EOS 违反。

> **协议级边界（批次 127 回灌，Jepsen 2024-11【定理级第三方证据】）**：[Jepsen 对 Bufstream 的评测](https://jepsen.io/analyses/bufstream-0.1.0) 发现 Kafka 事务协议的根本缺陷（KAFKA-17754）：事务协调者分区与数据分区的**分离使 `EndTxn` 缺乏全局顺序约束**，在故障窗口内可能出现 aborted 事务部分可见（aborted read）、丢失已提交写入与撕裂事务——**该缺陷影响 Apache Kafka、Bufstream 及所有 Kafka 协议兼容实现**。工程含义：①EOS 的结论以"单协调者无故障窗口"为隐含前提，跨故障场景须保留消费侧幂等兜底（本文 §1.63.6 的责任划分不变）；②评估 Kafka 兼容实现（Redpanda/AutoMQ/Bufstream）时，须索取其对 KAFKA-17754 的处置证据；③KIP-890 的防御增强不覆盖该协议层缺陷，修复需协议变更（关注 KIP 进展，季度复核跟踪）。详见 [conformance-matrix](../../Testing/06-契约语义测试/02-语义矩阵/conformance-matrix.md) 与 01-71 §1.71.4。

启用配置：

```properties
# Kafka Streams EOS v2 推荐配置
processing.guarantee=exactly_once_v2
commit.interval.ms=100
producer.enable.idempotence=true
```

### Flink Checkpoint 与两阶段提交

Apache Flink 通过 **Checkpoint** 实现内部状态的 exactly-once，并通过 **Two-Phase Commit（2PC）Sink** 将保证延伸至外部系统。

Flink 端到端 EOS 的架构：

```text
Kafka Source -> Flink Operators (state) -> Kafka Sink (transactional)
       ^                                        |
       |          checkpoint barrier            |
       +----------------------------------------+
```

执行流程：

1. **Checkpoint 触发**：JobManager 向 Source 注入 barrier，沿数据流传播。
2. **Source 快照**：Kafka Source 将当前消费 offset 随 checkpoint 状态持久化，但**不主动提交 offset 到 Kafka**。
3. **Operator 快照**：有状态算子将状态写入 RocksDB / 远端状态后端。
4. **Sink Pre-Commit**：barrier 到达 Kafka Sink 时，Sink flush 当前批次，调用 `preCommit()` 准备事务，但不提交。
5. **Checkpoint 完成**：JobManager 收到所有算子 ack 后，通知 Sink `commit()`。
6. **Sink Commit**：Kafka Sink 提交事务，输出正式可见。

Flink Kafka Sink 配置示例：

```java
KafkaSink<String> sink = KafkaSink.<String>builder()
    .setBootstrapServers("kafka:9092")
    .setRecordSerializer(KafkaRecordSerializationSchema.builder()
        .setTopic("output-topic")
        .setValueSerializationSchema(new SimpleStringSchema())
        .build())
    .setDeliveryGuarantee(DeliveryGuarantee.EXACTLY_ONCE)
    .setTransactionalIdPrefix("flink-eos-")
    .build();
```

【论证】Flink 的 EOS 与 Kafka Streams 的核心差异在于：Flink 以 **checkpoint** 为一致性边界，Kafka Streams 以 **Kafka 事务 commit interval** 为边界。Flink 需要外部 Sink 支持事务或幂等写；Kafka Streams 天然依赖 Kafka 事务。Flink 的优势是状态后端独立、容错粒度细；劣势是需要 Sink 配合 2PC，且事务 ID 管理在短 checkpoint 间隔下可能给 Kafka 协调器带来压力。

### Pulsar 事务现状

Apache Pulsar 自 2.8.0 引入事务 API，目标是实现端到端 exactly-once 流处理。其核心组件：

- **Transaction Coordinator（TC）**：管理事务生命周期；
- **Transaction Buffer**：暂存未提交消息，事务提交后才对消费者可见；
- **Acknowledgement within Transaction**：将消息确认纳入事务原子提交。

Pulsar 事务使用示例：

```java
Transaction txn = pulsarClient.newTransaction()
    .withTransactionTimeout(60, TimeUnit.SECONDS)
    .build().get();

producer.newMessage(txn).value(payload).send();
consumer.acknowledgeAsync(msg.getMessageId(), txn);
txn.commit();
```

【论证】Pulsar 事务已支持 `READ_COMMITTED` 隔离级别，并在 Pulsar Functions 中提供 exactly-once 语义。但截至 2026-11，Pulsar 事务生态成熟度仍低于 Kafka：部分客户端（如 Go、C++）对事务 API 的支持不完整，生产环境中更多采用“幂等生产者 + 去重表”或“Outbox + CDC”模式。Pulsar 的 effectively-once 语义（基于 broker 端 producer 去重）在无需事务时已能提供较强的单分区不重复保证。

---

## 1.63.5 外部系统桥接

消息系统的 exactly-once 无法自动延伸到数据库、缓存、外部 API 等异构系统。业界通过 Outbox、Inbox、Saga、CDC 等模式桥接。

### Outbox/Inbox 模式的形式化刻画

【论证】Outbox 模式的形式化目标可表述为：将“业务数据库更新”与“事件发布”两个动作转化为一个**本地 ACID 事务**内的两个写操作，从而把“双写问题”降级为“单库事务”。

设业务状态更新为 `ΔDB`，待发布事件为 `e`，则 Outbox 模式保证：

```text
T_outbox: write(ΔDB) ∧ write(outbox_record(e))  在同一本地事务中
           commit(T_outbox) → (ΔDB 持久化) ∧ (e 最终会被 relay 投递)
           abort(T_outbox) → (ΔDB 回滚) ∧ (e 不投递)
```

Inbox 模式则保证消费端幂等：

```text
T_inbox: if ¬exists(inbox_record(id(m))) then
            insert(inbox_record(id(m), PENDING))
            apply(ΔDB)
            update(inbox_record(id(m), SUCCESS))
         else
            skip
```

【论证】Outbox 解决“发事件”的原子性，Inbox 解决“收事件”的幂等性。两者合取，配合消息系统的 at-least-once 投递，即可在工程意义上实现端到端 exactly-once。该模式的形式化刻画与 [2.47 企业集成模式与事务消息模式](../02-场景驱动架构设计/02-47-企业集成模式与事务消息模式.md) 中的实现示例一致。

Outbox 表 DDL 示例：

```sql
CREATE TABLE outbox_events (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregatetype VARCHAR(255) NOT NULL,  -- 路由到 topic
    aggregateid   VARCHAR(255) NOT NULL,  -- Kafka message key
    type          VARCHAR(255) NOT NULL,  -- 事件类型
    payload       JSONB        NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);
```

Inbox 去重表 DDL 示例：

```sql
CREATE TABLE inbox_records (
    message_id   VARCHAR(255) PRIMARY KEY,
    source_topic VARCHAR(255) NOT NULL,
    processed_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    status       VARCHAR(32)  NOT NULL CHECK (status IN ('PENDING','SUCCESS','FAILED'))
);

CREATE INDEX idx_inbox_status ON inbox_records(status);
```

### Saga 补偿的最终一致语义

【论证】Saga 模式将长事务拆分为一系列本地事务 `T₁, T₂, ..., Tₙ`，每个本地事务提交后通过消息触发下一步；若某步失败，则按逆序执行补偿事务 `Cᵢ, ..., C₁`。

Saga 的形式化语义是**最终一致**而非强一致：

```text
Saga: T₁; T₂; ... ; Tₙ
      if ∃i, T_i fails then C_{i-1}; ... ; C_1
      eventually: all T committed OR all effects of committed T_j (j < i) compensated
```

与 2PC 的对比如下：

| 特性 | Saga | 2PC |
| --- | --- | --- |
| 一致性 | 最终一致 | 强一致 |
| 隔离性 | 无全局隔离 | 全局隔离 |
| 可用性 | 高 | 协调者单点风险 |
| 补偿复杂度 | 需业务定义补偿逻辑 | 自动回滚 |
| 适用场景 | 微服务长流程 | 短事务、强一致核心（逐渐淘汰） |

### Change Data Capture 路径

CDC 是 Outbox 模式最常见的 relay 技术。Debezium 读取数据库 WAL / binlog，将 `outbox_events` 表的变更转发到 Kafka。

Debezium Outbox Event Router 配置：

```json
{
  "name": "order-db-outbox-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "order-db",
    "database.port": "5432",
    "database.user": "debezium",
    "database.password": "***",
    "database.dbname": "orderdb",
    "database.server.name": "orderdb-server",
    "table.include.list": "public.outbox_events",
    "transforms": "outbox",
    "transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter",
    "transforms.outbox.route.topic.replacement": "outbox.event.${routedByValue}",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter"
  }
}
```

【论证】CDC relay 本身可能因崩溃重试而重复投递消息，因此下游消费端必须幂等。也就是说，CDC + Outbox 提供的是“业务事务与事件发布的原子性”，而非“端到端不重复”。重复风险由 Inbox/幂等消费承担。

---

## 1.63.6 语义边界：Exactly-once 不等于“应用不重复处理”

### Ack 点与副作用点分析

消息系统的 exactly-once 保证通常覆盖到“消息被成功确认”这一刻。但应用的业务副作用（写数据库、调用支付、发送短信）可能发生在 ack 之前或之后，从而引入重复生效风险。

| 副作用位置 | 行为 | 重复风险 | 推荐做法 |
| --- | --- | --- | --- |
| **先副作用，后 ack** | 处理完成再提交 offset | 副作用已生效但 ack 失败 → 消息重投 → 重复副作用 | 业务幂等或去重表 |
| **先 ack，后副作用** | 收到消息即 ack | ack 成功但处理失败/崩溃 → 消息丢失 | 仅适用于可丢失场景 |
| **副作用与 ack 原子** | 将副作用与 offset 提交纳入同一事务 | 需要外部事务支持（Kafka 事务、JDBC 事务） | 理想但复杂度高 |
| **幂等副作用** | 副作用本身幂等 | 重投无影响 | 最简洁可靠 |

【论证】“消息不重复到达应用”与“应用不重复处理”是两个不同层次的问题。消息系统只能保证前者；后者必须依赖应用的幂等设计。上表展示了不同 ack 位置下的风险分布，是评估端到端 exactly-once 时的核心检查表。

### Side Effect 去重的责任划分

端到端 exactly-once 的责任边界可总结为：

```text
+---------------------------------------------+
|  责任域           |  保证内容                 |
+-------------------+-------------------------+
|  消息系统          |  消息不重复入队、不重复投递  |
|  消息消费框架      |  offset 提交与消费进度一致   |
|  应用业务逻辑      |  副作用幂等或可撤销          |
|  外部系统          |  支持幂等写或事务写          |
+-------------------+-------------------------+
```

【论证】若外部系统本身不支持幂等（如某些 REST API、短信网关），则即使 Kafka/Flink 提供了系统级 EOS，端到端仍可能重复。此时必须在应用层引入去重键（如 event_id、message_id），或使用 Saga 补偿撤销副作用。

---

## 1.63.7 六系统语义能力对照总表与选型决策

下表对比 Kafka、Pulsar、RabbitMQ、NATS、MQTT、Redis Stream 在交付语义、事务、幂等、典型场景上的能力。

| 维度 | Kafka | Pulsar | RabbitMQ | NATS | MQTT | Redis Stream |
| --- | --- | --- | --- | --- | --- | --- |
| **at-most-once** | `acks=0` | Non-persistent | no-ack / auto-ack | Core NATS 默认 | QoS 0 | 不 ACK 即丢弃 |
| **at-least-once** | `acks=1/all` | Persistent 默认 | manual ack | JetStream ACK | QoS 1 | `XACK` 前可重投 |
| **exactly-once（协议/系统级）** | 幂等生产者 + 事务 + EOS | 事务（2.8+）+ effectively-once 去重 | 不支持原生 exactly-once | JetStream 事务模式 | QoS 2（仅协议级） | 不支持原生 exactly-once |
| **生产者幂等** | 原生支持 | 原生支持（broker 去重） | 需应用层实现 | 需应用层实现 | QoS 2 有去重 | 需应用层实现 |
| **事务能力** | 成熟（KIP-98/447/890） | 中等（2.8+ 事务 API） | AMQP 事务（范围有限） | JetStream 事务 | 无 | 无 |
| **流处理 EOS** | Kafka Streams / Flink | Pulsar Functions / Flink | 需自研 | 有限 | 不适用 | 有限 |
| **典型选型** | 高吞吐流处理、事件溯源 | 多租户、队列+流统一 | 传统企业集成、工作队列 | 云原生事件总线、边缘 | IoT 设备通信 | 轻量流处理、缓存内事件 |

选型决策树：

```text
1. 是否需要跨分区/跨主题的原子写？
   是 -> Kafka 事务 或 Pulsar 事务
   否 -> 下一步

2. 是否要求生产端去重（单会话）？
   是 -> Kafka 幂等生产者 / Pulsar effectively-once
   否 -> 下一步

3. 是否需要端到端 exactly-once（含外部 DB/API）？
   是 -> Outbox + Inbox + 幂等消费 或 Saga 补偿
   否 -> 下一步

4. 是否高吞吐流处理？
   是 -> Kafka + Kafka Streams/Flink EOS
   否 -> 根据延迟/生态选 Pulsar/RabbitMQ/NATS/MQTT/Redis
```

---

## 1.63.8 真实形式化资产与引用纪律

本文的“形式化”表述主要为符号化论证，置信级别已按 AGENTS.md §4.1 标注。以下公开形式化资产可直接引用：

| 资产 | 位置/链接 | 适用场景 | 引用纪律 |
| --- | --- | --- | --- |
| **Kafka KRaft TLA+ 规范** | apache/kafka 仓库 `metadata/src/main/resources/common/metadata/` | 元数据一致性、KRaft 协议 | 引用时说明是“经 TLC 检验的模型” |
| **Jepsen 评测** | [jepsen.io/analyses](https://jepsen.io/analyses) | Kafka、Redpanda、NATS JetStream 等一致性评测 | 必须附带被测版本号，禁止泛化为“该系统现在仍有此问题” |
| **KIP-98 / KIP-129 / KIP-447 / KIP-890** | Apache Kafka Wiki | Kafka 事务与 EOS 演进 | 必须标注版本范围与当前状态 |
| **Raft 论文** | Ongaro & Ousterhout, *In Search of an Understandable Consensus Algorithm* | 共识基础 | 引用而非自造 |
| **FLP 不可能性** | Fischer, Lynch, Paterson, 1985 | 异步系统共识不可能性 | 引用原始论文 |

关键引用示例：

- Jepsen Redpanda 21.10.1 报告明确指出其事务测试“未能获得 exactly-once 语义”，可能与测试结构有关（Redpanda 后续版本已修复多个相关问题）。
- Jepsen Bufstream 报告称其通过一致性评测，是少数经 Jepsen 验证的云原生 Kafka 实现之一。

【论证】引用 Jepsen 结论时必须连同版本号，因为分布式系统的实现会随版本快速演进；旧版本的评测结论不能直接套用到新版本。同样，KIP 状态（Adopted / Under Discussion / Released）和落地版本也必须按官方记录核实。

---

## 1.63.9 参考来源

- Apache Kafka — [KIP-98: Exactly Once Delivery and Transactional Messaging](https://cwiki.apache.org/confluence/display/KAFKA/KIP-98+-+Exactly+Once+Delivery+and+Transactional+Messaging)
- Apache Kafka — [KIP-129: Streams Exactly-Once Semantics](https://cwiki.apache.org/confluence/display/KAFKA/KIP-129%3A+Streams+Exactly-Once+Semantics)
- Apache Kafka — [KIP-447: Producer scalability for exactly once semantics](https://cwiki.apache.org/confluence/display/KAFKA/KIP-447)
- Apache Kafka — [KIP-890: Transactions Server-Side Defense](https://cwiki.apache.org/confluence/x/B40ODg)
- Apache Kafka — [Exactly-once Semantics are Possible: Here's How Apache Kafka Does it](https://www.confluent.io/blog/exactly-once-semantics-are-possible-heres-how-apache-kafka-does-it/)
- Apache Pulsar — [What are transactions?](https://pulsar.apache.org/docs/next/txn-what/)
- Apache Pulsar — [Effectively-Once Semantics in Apache Pulsar](https://www.splunk.com/en_us/blog/it/effectively-once-semantics-in-apache-pulsar.html)
- Apache Flink — [Exactly-Once Processing in Apache Flink](https://developer.confluent.io/learn/streamables/exactly-once-processing-in-apache-flink/)
- Debezium — [Outbox Event Router](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html)
- Jepsen — [Redpanda 21.10.1](https://jepsen.io/analyses/redpanda-21.10.1)
- Jepsen — [Analyses Index](https://jepsen.io/analyses)
- 项目内：
  - [1.4 形式化证明框架](01-04-形式化证明框架.md)
  - [1.25 Kafka 4.0 新时代与队列语义分析](01-25-Kafka-4.0新时代与队列语义分析.md)
  - [1.58 全局核心概念卡片总表](01-58-全局核心概念卡片总表.md)
  - [2.47 企业集成模式与事务消息模式](../02-场景驱动架构设计/02-47-企业集成模式与事务消息模式.md)

**最后更新**: 2026-11-18
