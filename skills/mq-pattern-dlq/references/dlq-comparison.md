# 六系统 DLQ 机制对比切片（派生自 02-17/03-44，派生日 2026-11-17）

> **时效声明**: 机制描述核实至 2026-01（随源文档）；各系统新版本的机制变化需复核官方文档。

## 对比矩阵

| 系统 | 内建死信 | 触发方式 | 典型实现 | 运维负担 |
|------|:---:|----------|----------|:---:|
| Kafka | ❌ | 消费失败计数超限 | 重试 topic 分层（biz→biz.retry→biz.dlq）+ 应用侧转移 | 高 |
| NATS JetStream | ⚠️ | `MaxDeliver` 用尽 | Nak 触发重投；用尽后依赖 `advisories` 捕获转存 | 中 |
| RabbitMQ | ✅ | 拒绝/TTL 过期/队列超限 | `x-dead-letter-exchange` + `x-message-ttl` | 低 |
| Pulsar | ✅ | 重试策略耗尽 | retry topic → dead letter topic（可配重试间隔） | 低 |
| Redis Stream | ❌ | 消费者长时间不 ACK（PEL） | 巡检 Pending 列表超时转移 + 人工处理 | 高 |
| MQTT | ❌（协议层） | broker 相关 | 依 broker 能力（如共享订阅+应用侧死信主题） | 中 |

## 关键机制要点

### Kafka（02-17.2）
- 处理失败 → 转发 `dlq-<topic>` 并提交位点（防阻塞主流程）。
- 分层重试：`biz.retry.10s/30s/5m` 带延迟转发；顶层 `biz.dlq` 长期保留。
- 死信 topic 同样受保留策略约束，监控其深度与最老消息年龄。

### RabbitMQ（02-17.4）
- 声明队列时加参数：`x-dead-letter-exchange`、`x-dead-letter-routing-key`、`x-message-ttl`、`x-max-length`。
- 死信触发三路径：消费者 nack/reject（requeue=false）、消息 TTL 过期、队列长度超限。

### NATS JetStream（02-17.3）
- `MaxDeliver` 控制最大投递次数；消费者 Nak 触发重投，用尽后消息停留并被 advisory 通知。
- 需自行消费 `$JS.EVENT.ADVISORY.CONSUMER.MAX_DELIVERIES.<stream>.<consumer>` 转存死信。

### Pulsar（源文档 01-12/02-17 口径）
- 订阅级重试策略：自动重试 topic（间隔可配）→ 耗尽进死信 topic；死信可被独立消费。

## 重试上限取值参考【估算】

- 默认上限 5~10 次（指数退避）；下游恢复 P99 决定总窗口应 > 下游恢复时间。
- 金融/订单类：上限低（3 次）+ 快速进死信 + 人工台兜底（时效优先）。
- 日志/埋点类：可丢弃场景可不设 DLQ，仅告警。

---
**同步规则**: 源文档更新后须重新派生并更新 derived-at / last-verified。
