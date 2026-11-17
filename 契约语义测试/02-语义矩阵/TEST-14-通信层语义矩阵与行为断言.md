# T.14 通信层语义矩阵与行为断言

> **置信口径**: 协议语义=【定理】；工程能力推断=【论证】；未标注数字按【估算】（AGENTS.md §4.1）。
> **时效声明**: 本文版本事实核实至 2026-11（Kafka 4.4 / Pulsar 5.0 / RabbitMQ 4.x / NATS 2.15 / Redis 8.x）。
> **本文档定位**: 契约语义测试 L4 层规范。定义 12 通信语义维度 × 六系统的支持能力矩阵与 GWT 行为断言库，是 TC-SEM 用例的生成源。能力结论只给等级+指针，论证过程见 topics 引用源，不重复论证。

## 目录

- [T.14 通信层语义矩阵与行为断言](#t14-通信层语义矩阵与行为断言)
  - [目录](#目录)
  - [T.14.1 十二语义维度定义](#t141-十二语义维度定义)
  - [T.14.2 能力矩阵（12 维 × 6 系统）](#t142-能力矩阵12-维--6-系统)
  - [T.14.3 GWT 行为断言库](#t143-gwt-行为断言库)
  - [T.14.4 TC-SEM 用例映射](#t144-tc-sem-用例映射)
  - [T.14.5 引用纪律](#t145-引用纪律)
  - [T.14.6 参考来源](#t146-参考来源)

---

## T.14.1 十二语义维度定义

| 维度 | 定义 | 测试关注点 | 论证源 |
| ---- | ---- | ---- | ---- |
| 交付语义 | 消息从生产到消费的保证等级：至多一次/至少一次/恰好一次 | 丢与重的取舍、幂等生产者与事务的启用条件 | 01-63 Exactly-once 全论证 |
| 顺序性 | 消息 observable 的顺序保证范围（分区/队列/全局） | 顺序范围声明、乱序场景的合法化判定 | 01-63/02-27 |
| 幂等去重 | broker/协议层消除重复消息的能力 | 去重域（生产者会话/消息 ID/窗口）、应用层兜底 | 01-63 |
| 重试退避 | 失败重投的语义（立即/退避/上限） | 重投放大、退避参数、毒消息收敛 | 01-65/02-16 |
| 死信 | 无法消费消息的隔离通道与再处理 | 进入条件、重投路径、监控指标 | 01-65 DLQ 工程解析 |
| 事务 | 跨消息/跨分区的原子提交 | 事务边界、fencing、悬挂事务防御 | 01-63（KIP-98/890） |
| 背压 | 生产快于消费时的流量控制机制 | 阻塞/丢弃/降级的触发点与观测 | 01-66 背压全谱系 |
| TTL过期 | 消息级存活时间，过期即失效 | broker 强制 vs 应用过滤、与 retention 区别 | 01-64/01-62 |
| 延迟消息 | 消息投递推迟到指定时刻/时长后 | 原生延迟 vs 定时任务模拟、时钟语义 | 02-16/02-57 |
| 消息过滤 | 订阅端/路由端选择消息的机制 | 服务端过滤 vs 客户端过滤的成本 | 02-14/01-64 |
| 流控 | 传输/协议层的速率与窗口控制 | 信用机制、窗口大小、阻塞传播 | 01-66 |
| 持久化 | 消息与拓扑的落地保证（重启不丢） | durable 声明矩阵、broker 重启行为 | 03-16/01-62 |

## T.14.2 能力矩阵（12 维 × 6 系统）

图例：**●** 原生支持；**◐** 配置/扩展支持（插件、x- 扩展或受限语义）；**○** 应用层实现（协议/broker 无，靠客户端模式）；**—** 无。

| 维度 | Kafka | RabbitMQ | NATS | Pulsar | Redis Stream | MQTT |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 交付语义 | ● acks=all+ISR 至少一次；事务恰好一次【定理】 | ● ack+confirm 至少一次 | ◐ Core 至多一次；JetStream 至少一次 | ● 至少一次；事务支持 | ○ 应用层（无 QoS） | ● QoS0/1/2 协议级【定理】 |
| 顺序性 | ● 分区内有序 | ● 单队列 FIFO | ◐ JetStream ordered consumer | ● 分区有序；Key_Shared 键有序 | ● Stream ID 单调有序 | ◐ 有序通道，QoS1 重可致重复 |
| 幂等去重 | ● 幂等生产者（PID+序列号） | ○ 应用层幂等键 | ◐ JetStream 窗口内 Msg-Id 去重 | ◐ broker deduplication 开关 | ○ XADD 应用层去重 | ○ 应用层 |
| 重试退避 | ◐ delivery.timeout+重试（无退避） | ○ 客户端重连 | ● maxDeliver+backoff（原生退避） | ● 消极确认延迟重投 | ○ 应用层 | ◐ 重连即重试 |
| 死信 | ◐ KIP-1191 Share Groups DLQ（4.4） | ● DLX 原生 | ◐ maxDeliver 耗尽转 DLQ subject | ● DLQ policy 原生 | — | ○ 实现层 |
| 事务 | ● 事务/EOS（KIP-98/890） | ○ 无跨消息事务（AMQP tx 单消息） | — | ● 事务（2.8+） | — | — |
| 背压 | ● producer buffer 阻塞 | ● prefetch/QoS+credit flow | ● maxAckPending/pull | ● receiverQueue | ○ 无原生（轮询补偿） | ● Receive Maximum |
| TTL过期 | ○ topic retention 非消息级 | ● per-message TTL+队列 TTL | ● maxAge/消息 TTL | ● topic 级 TTL | — | ● 消息过期（5.0）【定理】 |
| 延迟消息 | ○ 定时任务模拟 | ◐ 延迟插件/TTL+DLX 模式 | ○ 定时任务模拟 | ● deliverAfter 原生 | ○ 定时任务模拟 | ○ 实现层 |
| 消息过滤 | ○ 客户端过滤 | ● routing key+binding 灵活路由 | ● subject 通配符 | ◐ subscription filtering | ○ 客户端 | ● topic 通配符订阅【定理】 |
| 流控 | ● fetch 上限+配额 | ● credit flow（AMQP 1.0） | ● pending limits | ● receiver queue | ○ 无 | ◐ inflight 窗口 |
| 持久化 | ● segment 磁盘持久化 | ● durable 声明矩阵 | ◐ Core 内存；JetStream 持久 | ● 持久/非持久 topic | ● AOF/RDB+Stream | ◐ broker 配置决定 |

矩阵使用规则【论证】：单元格等级是"声明式可测"的起点——TC-SEM 用例对每个 **●/◐** 格生成正例（验证承诺成立），对每个 **○** 格生成模式用例（验证应用层实现遵守其契约），**—** 格生成反向用例（验证系统确实不承诺该语义，防止误用）。

## T.14.3 GWT 行为断言库

机读版见 [semantics/assertions.tsv](semantics/assertions.tsv)（id/dim/system/given/when/then/verdict 七列，批次75 的 TC 脚本直接引用 id）。文档示例：

```text
ASE-001 交付语义/Kafka
  GIVEN 生产者 acks=all、min.insync.replicas=2 的三 broker 集群
  WHEN 向 ISR 内两副本确认后broker 宕机其一
  THEN 已确认消息不丢（at-least-once 成立），重复消费在消费者可见
  VERDICT 消息存在性断言 + 重复计数 ≤1

ASE-002 死信/RabbitMQ
  GIVEN 队列绑定 DLX，消费者 nack(requeue=false) 三次
  WHEN 处理持续抛异常
  THEN 消息进入 DLX 路由的 DLQ，原队列清空，DLQ 可消费再处理
  VERDICT DLQ 深度=1 且原队列深度=0

ASE-003 背压/NATS
  GIVEN pull consumer maxAckPending=100，消费端不 ack
  WHEN 生产者持续投递
  THEN broker 在 100 条未确认处停止推送新批，无 OOM
  VERDICT 未确认数平台期=100

ASE-004 TTL过期/MQTT
  GIVEN MQTT 5.0 消息带 message expiry interval=2s，订阅者离线
  WHEN 订阅者 5s 后重连（会话过期=0）
  THEN 过期消息不投递（至多一次语义不违反）【定理】
  VERDICT 接收消息数=0
```

## T.14.4 TC-SEM 用例映射

每个维度生成一个父用例 TC-SEM-NN（覆盖六系统的等级核查），矩阵格展开为正例/模式/反向用例时编号 TC-SEM-NN-<系统>。父用例注册于 test-registry.tsv（域 SEM，环境 E2，状态 pending→scripted 随批次75 流转）。

| TC-SEM | 维度 | 覆盖策略 |
| ---- | ---- | ---- |
| TC-SEM-01 | 交付语义 | 每系统 ●/◐ 格正例 + EOS 边界（01-63 语义边界节） |
| TC-SEM-02 | 顺序性 | 分区/队列有序正例 + 跨分区无序合法化 |
| TC-SEM-03 | 幂等去重 | 幂等生产者/Msg-Id/dedup 开关正例 + 应用层幂等键模式 |
| TC-SEM-04 | 重试退避 | maxDeliver/backoff 正例 + 重试放大观测（α 系数） |
| TC-SEM-05 | 死信 | DLX/DLQ policy/maxDeliver 三路径正例 |
| TC-SEM-06 | 事务 | Kafka/Pulsar 事务提交与 fencing；无事务系统反向用例 |
| TC-SEM-07 | 背压 | maxAckPending/prefetch/receiverQueue 平台期断言（ASE-003 族） |
| TC-SEM-08 | TTL过期 | per-message TTL 与 retention 边界 |
| TC-SEM-09 | 延迟消息 | deliverAfter/插件模式正例 + 模拟模式时钟断言 |
| TC-SEM-10 | 消息过滤 | routing key/subject 通配符/订阅过滤正例 |
| TC-SEM-11 | 流控 | 信用/窗口机制的可观测断言 |
| TC-SEM-12 | 持久化 | broker 重启不丢声明矩阵逐格验证 |

## T.14.5 引用纪律

矩阵单元格不重复论证：交付语义/事务细节见 [01-63](../../topics/01-基础概念与对比分析/01-63-Exactly-once语义全论证.md)；DLQ 路径细节见 [01-65](../../topics/01-基础概念与对比分析/01-65-死信队列完整工程解析.md)；背压机制见 [01-66](../../topics/01-基础概念与对比分析/01-66-背压机制全谱系.md)；MQTT 协议语义【定理】见 [01-64](../../topics/01-基础概念与对比分析/01-64-MQTT-5.0协议全解析.md)。矩阵结论与引用源冲突时以引用源为准并回本表修正。

## T.14.6 参考来源

- 项目内：[01-63](../../topics/01-基础概念与对比分析/01-63-Exactly-once语义全论证.md)、[01-64](../../topics/01-基础概念与对比分析/01-64-MQTT-5.0协议全解析.md)、[01-65](../../topics/01-基础概念与对比分析/01-65-死信队列完整工程解析.md)、[01-66](../../topics/01-基础概念与对比分析/01-66-背压机制全谱系.md)、[02-16](../../topics/02-场景驱动架构设计/02-16-消息重试与幂等性设计.md)、[03-16](../../topics/03-架构与运维实践/03-16-安全加固指南.md)
- 外部：[Kafka producer configs](https://kafka.apache.org/documentation/#producerconfigs)、[RabbitMQ DLX](https://www.rabbitmq.com/dlx.html)、[NATS JetStream retention](https://docs.nats.io/nats-concepts/jetstream)、[Pulsar DLQ](https://pulsar.apache.org/docs/next/concepts-messaging/#dead-letter-topic)、[MQTT 5.0 OASIS](https://docs.oasis-open.org/mqtt/mqtt/v5.0/os/mqtt-v5.0-os.html)

---

**最后更新**: 2026-11-18
