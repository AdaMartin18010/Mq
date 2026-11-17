# Conformance 认证矩阵（L4 扩展 · 批次 80）

> **置信口径**: 官方 conformance 套件与 Jepsen 报告=【定理】级证据（第三方验证）；接入状态=【论证】。
> **时效声明**: 核实至 2026-11（Jepsen Bufstream 报告 2024-11、Redpanda 官方报告 2022-05）。
> **本文档定位**: TEST-14 语义矩阵的"自评"之上，叠加国际第三方 conformance 认证层。三类证据：协议 conformance 套件、一致性评测报告（Jepsen）、供应商官方测试集。

## 一、协议 Conformance 套件（官方 TCK）

| 协议/规范 | 权威来源 | 套件形态 | 本项目接入 |
| ---- | ---- | ---- | ---- |
| MQTT 5.0 | OASIS Standard（ISO/IEC 20922 配套） | Eclipse IoT / 商业 broker 的 TCK（如 Mosquitto 测试集、HiveMQ 合规套件） | 挂账：TC-SEM-MQTT-CONF 用例（真实 broker 启动后跑订阅时序断言，复用 01-64 时序图） |
| AMQP 1.0 | [ISO/IEC 19464](https://www.iso.org/standard/64955.html) + OASIS | Apache Qpid 互操作套件、OASIS AMQP 工作组测试 | 挂账：TC-SEM-AMQP-CONF（RabbitMQ qpidd 互操作对测） |
| CloudEvents 1.0.2 | CNCF | [CloudEvents SDK conformance](https://github.com/cloudevents/conformance)（cloudevents.dev 工具） | 可立即静态接入：信封必需字段断言（specversion/type/source/id——02-57 已核实），纳入 tc-assert-check 扩展 |
| Kafka 协议 | 事实标准（Apache） | 无官方 TCK；生态准绳=librdkafka 测试集 + Jepsen 共享 harness | 经 Jepsen 行（§二）覆盖 |
| AsyncAPI 3.0 | AsyncAPI Initiative | asyncapi validate（官方 CLI）+ 本项目 contract-spec-check | ✅ 已接入（E0 第 6 步） |
| OpenTelemetry Messaging Semconv | CNCF | semconv 校验器（weaver） | 挂账：批次 85 |

## 二、Jepsen 一致性证据表（引用纪律：带版本号）

| 被测系统 | 报告 | 关键结论 | 对本项目的影响 |
| ---- | ---- | ---- | ---- |
| Bufstream 0.1.0~0.1.3 | [Jepsen 2024-11](https://jepsen.io/analyses/bufstream-0.1.0) | 3 safety + 2 liveness 问题，0.1.3 全修复；**核心发现：Kafka 协议的事务机制根本不健全**（协调者分区与数据分区分离导致 aborted 事务可能部分可见）——影响 Apache Kafka、Bufstream 及所有 Kafka 兼容系统 | 【定理级证据】01-63 的 Kafka EOS 论证需补充该边界（已在 conformance 层登记，01-63 正文更新列入下批）；选型树（01-59）EOS 分支加"协议级 unsound 风险"注记 |
| Redpanda 21.10.1 | [Jepsen 官方报告](https://www.redpanda.com/blog/redpanda-official-jepsen-report-and-analysis)（2022-05 官方分析与修复说明） | 读写冲突等问题的发现与修复 | 01-28/03-27 版本事实源；Jepsen 引用纪律范例（带版本号不泛化） |
| Kafka（经 Bufstream 报告反照） | 同上 Bufstream 报告 §4 | Kafka Java client 缺陷（Consumer.close() 无限阻塞、offset 不可预测）+ 事务协议 unsound | 01-63 §1.63.8 形式化资产节增补指针挂账 |

## 三、供应商官方测试集（次级证据，标注独立性）

| 系统 | 官方测试资产 | 独立性标注 |
| ---- | ---- | ---- |
| Kafka | Apache Kafka 仓库 tests、ducktape 系统测试 | 自证（非第三方），证据等级低于 Jepsen |
| Pulsar | 仓库集成测试 + BookKeeper Jepsen 类验证（社区） | 自证 |
| NATS JetStream | Synadia 内部一致性测试（公开资料有限） | 自证；【估算】社区第三方评测稀少 |
| RabbitMQ | 仓库 common_test 套件 | 自证 |

规则【论证】：自证资产只用于"补充覆盖维度"，不用于"语义等级结论"；语义结论必须 Jepsen/官方规范双源之一。

## 四、接入路线图

1. **已接入**：AsyncAPI 3.0（E0 第 6 步）、CloudEvents 信封静态断言（批次 85 并入 tc-assert-check）。
2. **下一批（真实执行批次）**：MQTT TCK 子集（mosquitto 启动 + 01-64 QoS 时序断言自动化）、AMQP 互操作对测。
3. **文档回灌挂账**：01-63 补 Kafka 事务 unsound 边界（Jepsen 2024-11 引用）、01-59 EOS 决策分支注记——列入 ROADMAP 待办。

---

**最后更新**: 2026-11-18
