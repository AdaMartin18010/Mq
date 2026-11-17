# MQ 绑定矩阵（L3 层）

> **置信口径**: 绑定字段集=【定理】（asyncapi/bindings 官方规范逐字核实至 2026-11）；覆盖度推断=【论证】。
> **本文档定位**: L3 层——AsyncAPI bindings 官方绑定在 server/channel/operation/message 四级的字段覆盖矩阵，及本项目 spec 的 x- 扩展登记簿。contract-binding-check.sh 的机器规则以本表为准。

## 一、版本基线（WebSearch 核实）

| 系统 | 绑定名 | 版本 | 来源 |
| ---- | ---- | ---- | ---- |
| Kafka | kafka | 0.5.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/kafka) |
| MQTT | mqtt | 0.2.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/mqtt) |
| AMQP 0-9-1 | amqp | 0.3.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/amqp) |
| NATS | nats | 0.1.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/nats) |
| Pulsar | pulsar | 0.1.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/pulsar) |
| Redis | redis | 0.1.0 | [官方 binding 页](https://www.asyncapi.com/docs/reference/bindings/redis) |

## 二、四级字段覆盖矩阵

图例：**●**=有字段集；**R**=保留空（MUST NOT contain properties）；字段列出核心集（以官方页全表为准）。

| 系统 | server | channel | operation | message |
| ---- | ---- | ---- | ---- | ---- |
| Kafka | ● schemaRegistryUrl/Vendor、brokerId/brokerVersion、bindingVersion | ● partitions、replicationFactor、bindingVersion | ● groupId、clientId | ● key(schema)、bindingVersion |
| MQTT | ● clientId/cleanSession/lastWill/keepAlive/sessionExpiryInterval(v5)/maximumPacketSize | **R** | ● qos/retain/messageExpiryInterval(v5) | ● payloadFormatIndicator/correlationData/responseTopic/contentType（均 v5） |
| AMQP | **R** | ● is/exchange/queue | ● expiration/priority/deliveryMode/mandatory/replyTo/timestamp/ack/userId/cc/bcc | **R** |
| NATS | **R** | **R** | ● queue(≤255)、bindingVersion | **R** |
| Pulsar | ● tenant(默认 public) | ● namespace*/persistence*/compaction/geo-replication/retention/ttl/deduplication | **R** | **R** |
| Redis | **R** | **R** | **R** | **R**（全保留，唯一全空绑定） |

## 三、本项目 x- 扩展登记簿（01-44 等价转换策略的落地清单）

| 扩展名 | 所在 spec | 语义 | 官方未覆盖原因 |
| ---- | ---- | ---- | ---- |
| x-jetstream | nats（operation 级） | stream/retention/durable/maxAckPending/ackPolicy/maxDeliver | nats binding 仅定义 Core queue |
| x-prefetch | amqp（operation 级） | basic.qos prefetch count/global | amqp binding operation 无 QoS 字段 |
| x-pulsar-subscription | pulsar（operation 级） | subscription name/type/receiverQueueSize | pulsar operation 保留空 |
| x-redis | redis（channel/operation 级） | maxlen/trimStrategy/XADD/XREADGROUP 全参数 | redis binding 全保留 |
| x-semantics | 场景包（operation 级） | 引用 TEST-14 十二维度清单 | 语义维度非协议绑定范畴 |

登记规则【论证】：新 x- 扩展必须先入本表（含语义与理由）再进 spec；contract-binding-check.sh 对未登记扩展告警（WARN），对登记扩展做结构存在性检查。

## 四、已发现的绑定层修正项

1. **config-templates/asyncapi-mqtt-example.yaml**：qos/retain/expiryInterval 写在 channel 级——按 mqtt binding 0.2.0 应为 operation 级（channel 为保留空）。批次72 修复目标（contract-binding-check 的违规实例）。
2. Kafka 示例的 channel 级 partitions/replicationFactor 符合 kafka binding（channel 有字段集），无需修正。

## 五、与 config-templates 的映射

每系统 spec ↔ broker 配置模板的映射表与漂移检测见 [../../topics/scripts/contract-drift-check.sh](../../../topics/scripts/contract-drift-check.sh)（参数级）与本表（结构级）。绑定参数名与模板可配项的命名差异（如 replicationFactor ↔ default.replication.factor）是**跨层命名映射**议题，归批次76 追溯表统一登记。

---

**最后更新**: 2026-11-18
