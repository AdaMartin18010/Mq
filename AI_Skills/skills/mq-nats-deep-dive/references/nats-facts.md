# NATS 2.x 事实切片（派生自 01-26，派生日 2026-11-18）

> **时效声明**: 版本事实核实至 2026-11（随源文档）；NATS 新版本发布后 30 天内更新。

## 双层架构

```text
应用层：pub/sub、request/reply、services、queue groups
Core NATS：无状态消息总线，at-most-once，纯内存路由
JetStream：Stream/Consumer/KV/ObjectStore，at-least-once，Raft 复制
传输：NATS 文本协议 / TLS / WebSocket / MQTT 网关 / Leafnode
```

## Core NATS 要点

- **at-most-once**：只投当前在线订阅者；断线即丢（无持久化）。
- **subject**：点分字符串（`orders.us.1001`），`*` 匹配单段、`>` 匹配剩余所有段。
- **queue group**：同名 queue 的订阅者间负载均衡（每组一条）。
- **request/reply**：`reply-to` subject 实现 RPC；超时需应用层设置。

## JetStream 要点

- **Stream**：服务器端存储，绑定 subject，按策略保留（limits/interest/workqueue）。
- **Consumer**：有状态视图，维护位点/重试/投递策略；未 ack → redelivery（受 AckWait 约束）。
- **MaxDeliver**：最大投递次数，用尽触发 advisory（`$JS.EVENT.ADVISORY.CONSUMER.MAX_DELIVERIES.*`），配合转存实现死信。
- **KV / ObjectStore**：基于 Stream 的键值与对象抽象（2.6+ 引入，2.10/2.11 成熟）。

## 版本演进（项目文档基线）

| 版本 | 发布 | 关键特性 | 状态 |
| ------ | ------ | ---------- | ------ |
| 2.10.0 | 2023-09 | subject transforms、S2 压缩、Auth Callout、consumer 多 subject 过滤、MQTT QoS 2 | End of life |
| 2.10.26 | 2025-03 | 2.10 长期维护终点（官方称史上最稳 2.10） | End of life |
| 2.11.0 | 2025-03-19 | 单消息 TTL、consumer priority groups、consumer pause、分布式消息追踪、stream multi-get | End of life |
| 2.12.0 | 2025-09-22 | Atomic batch publish、delayed message scheduling、distributed counters、Prioritized pull policy、mirror promotion | End of life |
| 2.13.x | — | 官方跳过，从未发布 | Skipped |
| 2.14.0 | 2026-04-30 | Fast batch publish、recurring schedules、scheduled subject sampling、可靠 WQ/Interest sourcing | Maintained |
| 2.15.0 | 2026-09-17 | Desired State Reconciliation、Stream backup v2、source recreate indexing、`sync: always` 性能、默认 `max_consumers=1000` | Latest |

> 生产环境优先使用 2.14 或 2.15；2.13 跳过未发布，升级路径不存在 2.13 这一环。

## 选型对比速答【论证】

- vs Kafka：NATS 胜在延迟与运维简单（单二进制、无外部依赖）；Kafka 胜在生态与回放/分析。
- vs RabbitMQ：NATS Core 语义更轻（无 broker 队列持久化负担）；需要复杂路由选 RabbitMQ。
- MQTT 集成：NATS 2.x 可内嵌 MQTT 网关（QoS 2 支持见 2.10+），IoT 与微服务可共集群。
- API level：JetStream 功能按 API level 门控，客户端可在请求头携带 `Nats-Required-Api-Level` 要求服务端支持指定 level，滚动升级期间可防旧客户端被新语义误伤。

---
**同步规则**: 源文档更新后须重新派生并更新 derived-at / last-verified。
