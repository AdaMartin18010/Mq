# 业务场景契约库（03-业务场景/）

> L5 层：8 个通用业务场景 × 消息模式的契约包。每场景 3 文件：`contract.yaml`（DSL 契约）/ `asyncapi.yaml`（spec，operations 带 `x-semantics` 标注）/ `SEMANTICS.md`（语义维度标注+验收关注点）。
> 规范见 [../00-模型与规划/TEST-13](../00-模型与规划/TEST-13-六层契约语义测试模型与规划.md) 与 [TEST-15](../00-模型与规划/TEST-15-业务场景契约库与用例规范.md)；语义维度标准清单见 [../02-语义矩阵/TEST-14](../02-语义矩阵/TEST-14-通信层语义矩阵与行为断言.md)。

## 场景速查

| 场景 | 目录 | 核心语义维度 | 主系统 |
| ---- | ---- | ---- | ---- |
| 订单全链路 | 01-order-lifecycle | 交付语义/顺序性/幂等去重/死信/事务 | Kafka |
| 支付与对账 | 02-payment-reconciliation | 交付语义/幂等去重/持久化/顺序性 | Kafka |
| 库存扣减 | 03-inventory | 事务/幂等去重/顺序性/背压/TTL过期 | Kafka |
| 通知广播 | 04-notification | 消息过滤/持久化/重试退避/死信 | RabbitMQ |
| IoT 遥测 | 05-iot-telemetry | 交付语义/TTL过期/流控/背压 | MQTT |
| CDC 同步 | 06-cdc-sync | 顺序性/持久化/幂等去重/背压 | Kafka |
| 审计日志链 | 07-audit-trail | 持久化/顺序性/交付语义 | Pulsar |
| 任务队列 | 08-task-queue | 重试退避/死信/延迟消息/幂等去重 | NATS JetStream |

## 使用约定

- **契约复用**：信封类结构引用 config-templates 模板（task-envelope / cdc-debezium / webhook-delivery），不复制字段。
- **语义标注**：`x-semantics` 值必须逐字取自 TEST-14 十二维度清单；新增维度须先改 TEST-14。
- **系统切换**：场景与系统解耦，换系统只需换 `asyncapi.yaml` 的 servers/bindings；SEMANTICS.md 的矩阵格引用同步核对。
- **用例生成**：批次75 的 TC-BUS 用例以本库 contract.yaml 为输入断言源。

**最后更新**: 2026-11-18
