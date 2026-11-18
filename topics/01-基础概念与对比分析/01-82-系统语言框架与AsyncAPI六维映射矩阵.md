# 01-82 系统语言框架与 AsyncAPI 六维映射矩阵

> **置信口径**: binding/框架字段=【定理】（官方规范与文档，版本见 01-73~76）；断点分析=【论证】。
> **时效声明**: 核实至 2026-11（框架版本引 01-73~76 已核实来源）。
> **本文档定位**: 批次 113 旗舰。系统 × 语言 × 框架 × AsyncAPI binding × 代码生成器 × 配置参数 的六维联动映射——01-73~76 四篇语言深耕的横向贯通层，01-77 跨语言集成测试（XLAN）的输入源。

## 目录

- [01-82 系统语言框架与 AsyncAPI 六维映射矩阵](#01-82-系统语言框架与-asyncapi-六维映射矩阵)
  - [目录](#目录)
  - [1.82.1 六维模型与 10 条端到端链](#1821-六维模型与-10-条端到端链)
  - [1.82.2 生成器支持矩阵](#1822-生成器支持矩阵)
  - [1.82.3 映射断点分析](#1823-映射断点分析)
  - [1.82.4 绑定→框架→部署 速查表](#1824-绑定框架部署-速查表)
  - [1.82.5 与 XLAN 用例的接口](#1825-与-xlan-用例的接口)
  - [1.82.6 参考来源](#1826-参考来源)

---

## 1.82.1 六维模型与 10 条端到端链

六维链式模型【论证】：`binding 参数 → AsyncAPI 声明 → 生成器产物 → 框架配置 → 部署模板 → 运行行为`。全组合 6 系统 × 5 语言 × 28 框架爆炸，故选 10 条代表链（每系统 ≥1 条 + 2 条跨系统对比）：

| # | 链 | binding→框架配置→部署 关键映射 |
| ---- | ---- | ---- |
| 1 | Kafka×Go | partitions→sarama `NumPartitions`/segmentio 隐式→`kafka-topics --create`→config-templates/kafka-server.properties |
| 2 | Kafka×Python | replicationFactor→confluent-kafka 无副本概念（broker 侧）→`default.replication.factor`→同模板 |
| 3 | MQTT×TS | qos(oper 级 0.2.0)→mqtt.js `{qos, retain}`→mosquitto listener→mqtt-broker-config.conf |
| 4 | MQTT×Rust | messageExpiryInterval→rumqttc `unwrap` 需手动（断点#2）→同模板 |
| 5 | NATS×Go | x-jetstream.maxAckPending→nats.go `MaxAckPending`→nats-server.conf.template JetStream 块 |
| 6 | NATS×Python | x-jetstream.backoff→nats-py `backoff` 参数→同模板 |
| 7 | AMQP×Go | x-prefetch.count→amqp091-go `Qos(prefetch_count=)`→rabbitmq.conf.template |
| 8 | Pulsar×Rust | ttl/deduplication→pulsar-rs 客户端无 broker 开关（断点#3）→pulsar-broker-config.conf |
| 9 | Redis×Go | x-redis.count/block→go-redis `XReadGroupArgs{Count, Block}`→redis-stream-config.conf |
| 10 | Kafka×Rust（对照 #1） | 同 binding→rdkafka `topic.num.partitions` 创建参数→同模板——跨语言一致性验证链 |

每条链的三层一致性验证（XLAN-A 族的输入）【论证】：binding 声明值 = 框架配置值 = 部署模板值，任何两层不一致即漂移。

## 1.82.2 生成器支持矩阵

@asyncapi/modelina（v5.10.1，2025-10 核实）现状【论证】：

| 维度 | 现状 | 对六维链的影响 |
| ---- | ---- | ---- |
| payload 类型生成 | 全语言成熟 | 维度 4 可靠 |
| binding 信息保留 | 丢失（仅 payload/headers 类型） | 维度 3→4 断点（断点#1） |
| x- 扩展 | 默认不进生成物 | x-jetstream/x-redis 链全人肉 |
| operation.action | 映射各语言消费/生产骨架 | 可用但需人工补语义 |
| 自定义模板 | 支持（generator SDK） | 长期解：自建模板保留 binding |

结论【论证】：**"AsyncAPI 生成可运行框架代码"在当前生态是半程车票**——类型层自动化、配置层手工。这决定了 113 的核心价值是"把手工层文档化到可核对"。

## 1.82.3 映射断点分析

| 断点 | 位置 | 影响 | 补偿模式 |
| ---- | ---- | ---- | ---- |
| #1 binding→代码 | 生成器丢 binding | 配置全靠人肉 | contract-binding-check + 本矩阵速查表双保险 |
| #2 MQTT v5 属性 | 部分客户端不暴露 expiry | TTL 语义静默丢失 | 应用层信封补 time 字段（契约兜底） |
| #3 broker 开关 | 客户端 API 无 broker dedup/ttl | 声明与执行分离 | 部署模板联动核查（drift-check） |
| #4 x- 扩展 | 无工具链理解 | JetStream/Stream 语义不可机验 | 登记簿+结构检查（已落地） |
| #5 跨层命名 | replicationFactor↔default.replication.factor | 检索漂移 | 本矩阵 §1.82.4 命名映射表 |

## 1.82.4 绑定→框架→部署 速查表

| 系统 | binding 字段 | 框架配置对象.字段（代表） | 部署模板参数名 |
| ---- | ---- | ---- | ---- |
| Kafka | partitions | sarama: `NumPartitions`; rdkafka: 创建参数 | `num.partitions`（默认） |
| Kafka | replicationFactor | （broker 侧） | `default.replication.factor` |
| MQTT | qos / retain | mqtt.js `{qos,retain}`; paho `qos` | `listener` + ACL |
| NATS | maxAckPending（x-） | nats.go `MaxAckPending`; nats-py 同 | `max_ack_pending` |
| AMQP | prefetch（x-） | amqp091-go `Qos`; amqplib `prefetch` | `consumer_timeout` 相关 |
| Pulsar | ttl / deduplication | （broker 侧；客户端订阅参数另列） | `ttlSeconds`/`brokerDeduplicationEnabled` |
| Redis | count/block/noack（x-） | go-redis `XReadGroupArgs`; redis-rs 同构 | `stream-*` 配置族 |

## 1.82.5 与 XLAN 用例的接口

- XLAN-A（序列化对等）：本矩阵 §1.82.1 的 10 链是 20 有向边的精选核；
- XLAN-B（语义对等）：断点 #2/#3 的补偿模式必须在各语言实现中一致（契约层兜底的统一性）；
- 回归触发：binding-matrix 或任一框架版本变更 → `hermes-task-gen --drift 01-82` 全链重跑。

## 1.82.6 参考来源

- 项目内：[01-73](01-73-Python消息客户端工程深耕.md)、[01-74](01-74-TypeScript-JavaScript消息客户端工程深耕.md)、[01-75](01-75-Go消息客户端工程深耕.md)、[01-76](01-76-系统编程语言消息客户端工程深耕.md)、[01-77](01-77-跨语言集成测试与DSL转换链.md)、[bindings-matrix](../../Testing/06-契约语义测试/01-契约规格/bindings-matrix.md)、[01-32](01-32-AsyncAPI工程生态深度分析.md)
- 外部：[AsyncAPI modelina](https://github.com/asyncapi/modelina)、[sarama config](https://github.com/IBM/sarama)、[nats.go JetStream](https://github.com/nats-io/nats.go)、[go-redis streams](https://redis.uptrace.dev/guide/go-redis-streams.html)

---

**最后更新**: 2026-11-18
