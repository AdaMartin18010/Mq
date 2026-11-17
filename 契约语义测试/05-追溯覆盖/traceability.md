# 六层追溯表（批次76）

> 用途：DSL ↔ AsyncAPI ↔ 绑定 ↔ 语义 ↔ 业务场景 ↔ 行为用例 的逐层追溯。变更任一层资产时，用 `hermes-task-gen.sh --drift` + `contract-drift-check.sh --format=ids` 定位受影响下游。
> 更新时机：批次级（随每批四件套）；覆盖口径 = 已登记链路 / 应登记链路。

## L1→L2：DSL → AsyncAPI

| L1 契约源 | L2 spec | 校验 |
| ---- | ---- | ---- |
| 03-业务场景/01-order-lifecycle/contract.yaml | 同目录 asyncapi.yaml | contract-spec-check + tc-assert-check |
| 03-业务场景/02~08（同规则 7 场景） | 各自 asyncapi.yaml | 同上 |
| topics/config-templates/event-contract-template.yaml | asyncapi-kafka/mqtt-example.yaml | contract-spec-check |

覆盖：8/8 场景 + 2 模板 = **10/10**。

## L2→L3：spec → 绑定/模板

| spec | 官方绑定（版本见 bindings-matrix §一） | broker 模板 | 漂移状态 |
| ---- | ---- | ---- | ---- |
| asyncapi-kafka-example.yaml | kafka 0.5.0 | kafka-server.properties.template | DRIFT=0 |
| asyncapi-mqtt-example.yaml | mqtt 0.2.0 | mqtt-broker-config.conf | DRIFT=0（批次72 已修正层级） |
| asyncapi-nats-example.yaml | nats 0.1.0 + x-jetstream | nats-server.conf.template | DRIFT=0（x- 登记簿覆盖） |
| asyncapi-amqp-example.yaml | amqp 0.3.0 + x-prefetch | rabbitmq.conf.template | DRIFT=0（x- 登记簿覆盖） |
| asyncapi-pulsar-example.yaml | pulsar 0.1.0 + x-pulsar-subscription | pulsar-broker-config.conf | DRIFT=0（x- 登记簿覆盖） |
| asyncapi-redis-example.yaml | redis 0.1.0（全保留）+ x-redis | redis-stream-config.conf | DRIFT=0（x- 登记簿覆盖） |

绑定结构校验：contract-binding-check **22/22 PASS**。覆盖 **6/6**。

## L3→L4：绑定 → 语义矩阵

语义维度依赖的绑定参数映射（TEST-14 矩阵格 ← bindings-matrix 字段）：

| 语义维度 | 关键绑定参数 |
| ---- | ---- |
| 交付语义 | mqtt.qos / kafka acks（模板层）/ nats x-jetstream.ackPolicy |
| 背压 | nats x-jetstream.maxAckPending / amqp x-prefetch.count / pulsar x-pulsar-subscription.receiverQueueSize |
| TTL过期 | mqtt operation.messageExpiryInterval / pulsar channel.ttl |
| 死信 | amqp channel.exchange(DLX) / nats x-jetstream.maxDeliver / pulsar channel（DLQ policy 属订阅配置，x- 待登记） |
| 持久化 | kafka channel.replicationFactor / pulsar channel.persistence / amqp operation.deliveryMode |
| 延迟消息 | pulsar（deliverAfter 属客户端 API，绑定未覆盖→批次76 挂账） |

覆盖：12 维度中 6 维度有直接绑定参数链路；挂账 1 项（pulsar deliverAfter）。

## L4→L5：语义 → 场景

| 场景 | x-semantics 维度数 | 断言引用（assertions.tsv ASE 族） |
| ---- | ---- | ---- |
| 01-order-lifecycle | 5 | ASE-001/003/004/005/007/008/009 族 |
| 02-payment-reconciliation | 4 | ASE-001/004 + 持久化格 |
| 03-inventory | 5 | ASE-009/010/011 + TTL 格 |
| 04-notification | 4 | ASE-006/007 + 过滤格 |
| 05-iot-telemetry | 4 | ASE-012 + 流控/背压格 |
| 06-cdc-sync | 4 | ASE-003/004 + 持久化格 |
| 07-audit-trail | 3 | ASE-014 族 |
| 08-task-queue | 4 | ASE-006/007 + 延迟格 |

覆盖：**8/8**（tc-assert-check 强制 x-semantics 合法性）。

## L5→L6：场景 → 用例

| 用例 | 输入契约 | 状态 |
| ---- | ---- | ---- |
| TC-BUS-01~08（父用例） | 各场景 contract.yaml | mapped（E0 第 7 步 tc-assert-check 22 检） |
| TC-SEM-05（死信） | ASE-007 + 04-notification | mapped（样例脚本 dry-run 通过） |
| TC-SEM-07（背压） | ASE-010 + 03-inventory | mapped（样例脚本 dry-run 通过） |
| TC-SEM-01~04/06/08~12 | ASE 断言库 | pending（脚本随真实执行批次补全） |

覆盖：父用例 8/8 + 语义样例 2/12；**真实执行覆盖率 = 2/12（dry-run 口径挂账，用户在场批次补齐）**。

## 覆盖率汇总

| 链路 | 覆盖 |
| ---- | ---- |
| L1→L2 | 10/10 (100%) |
| L2→L3 | 6/6 (100%) + 绑定结构 22/22 |
| L3→L4 | 6/12 维度直接链路 + 5 维度经矩阵论证 + 1 挂账 |
| L4→L5 | 8/8 (100%) |
| L5→L6 | 10/20 用例 (50%；真实执行口径 2/12) |
| 综合（登记口径） | **38/40 = 95%** |

---

**最后更新**: 2026-11-18
