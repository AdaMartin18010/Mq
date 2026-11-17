# 权威学习路径图（Learning Path）

> **定位**: 批次 92。把知识库 235 篇主题文档与国际权威教材/论文编织为学习导航。教材版本事实以官方页面为准（核实至 2026-11）。
> 用法：按角色选入口；每个阶段"先读书建骨架，再用知识库填血肉，最后用契约语义测试做实验"。

## 路径一：架构师（选型与治理）

| 阶段 | 教材（国际权威） | 知识库对应 | 验证 |
| ---- | ---- | ---- | ---- |
| 1. 概念地基 | 《Enterprise Integration Patterns》（Hohpe & Woolf，EIP 官方站） | 01-05 程序设计模式 / 02-12~52 专项模式 / [EIP 全目录](批次29 已对齐) | 01-58 概念卡片自测 |
| 2. 事件驱动架构 | 《Designing Event-Driven Systems》（Kleppmann，[Confluent 官方免费](https://www.confluent.io/designing-event-driven-systems/)） | 01-06/01-07 架构演进 / 02-01~11 案例 / 02-47 事务模式 | 01-59 决策树演练 |
| 3. 数据契约 | AsyncAPI 官方文档 + [ODCS v3.1.0 规范](https://bitol.io/) | 01-30/01-32/01-37 / 02-54~57 | 契约语义测试 03-业务场景 实操 |
| 4. 治理深化 | 《Building Event-Driven Microservices》（Bellemare） | 01-37 组织级 / 02-48 工作流 | governance-tools.md 三件套 |

## 路径二：工程师（实现与运维）

| 阶段 | 教材/规范 | 知识库对应 | 验证 |
| ---- | ---- | ---- | ---- |
| 1. 协议 | MQTT 5.0 OASIS 规范原文 / [Kafka 协议指南](https://kafka.apache.org/protocol.html) | 01-64 / 01-71（wire protocol） | 报文字段默写级理解 |
| 2. 六系统实操 | 各系统官方文档 | 03-01~14 部署 / config-templates 58 模板 | mq-smoke-test E1 |
| 3. 语义深水区 | Kleppmann 事务章节 + [Jepsen 报告](https://jepsen.io/analyses) | 01-63 EOS / 01-66 背压 / conformance-matrix | TC-SEM 断言库演练 |
| 4. 可靠性 | 《Chaos Engineering》（Basi et al.）+ Chaos Mesh 文档 | 04-04 / Testing/06-混沌 | GAME DAY 参与 |

## 路径三：研究者（形式化与前沿）

| 阶段 | 材料 | 知识库对应 |
| ---- | ---- | ---- |
| 1. 一致性理论 | Raft 论文 / Paxos 论文（AGENTS.md §4.2 真实形式化资产） | 01-04 形式化框架 / 01-13 KRaft / 01-62 Oxia |
| 2. 系统动力学 | Meadows《Thinking in Systems》 | 04-01~06 全系列（项目特色） |
| 3. 前沿跟踪 | Kafka KIP 列表 / Pulsar PIP / CNCF TAG 白皮书 | 01-60 前沿瞭望（月度） |

## 使用纪律

- 教材结论与知识库冲突时：协议级以规范为准，工程级以官方文档+实测为准，并回报修正（AGENTS.md §6）；
- 每完成一阶段，在 [GLOSSARY](GLOSSARY.md) 标注掌握度，驱动术语表个性化。

---

**最后更新**: 2026-11-18
