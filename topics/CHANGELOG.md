# 更新日志（Changelog）

> **归并说明**: 2026-01-06 治理批次中，原 2.x–6.4.x 共 30+ 个版本（均标注 2025-12-31 同日、每个仅新增 1-2 个文件）已按语义归并为下述版本。历史细节见 Git 提交记录。

## [3.6.0] - 2026-11-17

### 批次15：版本追踪清单核实更新（P4 机制落地）

- ✅ ROADMAP 版本追踪清单全表重写并核实至 2026-11（WebSearch 多源）：Kafka 4.4.0（2026-10-22，三版本支持策略）、Pulsar 4.1.3 + 5.0.0-M1（5.0 预计 10 月 GA）、RabbitMQ 4.4.0（3.13/4.0/4.1 须先迁 4.2）、NATS 2.15（2.11/2.12 已 EOL）、Redis 8.x 三许可证 + Valkey 9.x 对照、RocketMQ 5.5.1、Redpanda v26.2（CalVer + 发版渠道变更）、MQTT 5.0 仍为现行标准
- ✅ 每系统附"差距与行动"列 + 例行更新规则（季度复核，大版本 GA 30 天内更新专章）
- 波及说明：专章正文演进段更新（01-12/01-15/01-17/01-25/01-26/01-27/01-28/03-27）并入批次16a 置信标注批一并执行

## [3.5.0] - 2026-11-17

### 批次14：AsyncAPI 工程生态专批（前沿补章扩展）

- ✅ 新建 01-32 AsyncAPI 工程生态深度分析：Generator/Modelina 代码生成能力与质量边界、Spectral/Parser/CLI/Diff 治理链、Studio/事件目录/Mock 交互层、Springwolf/FastStack 框架集成、绑定版本史与端到端流程（版本事实 WebSearch 核实至 2026-11：规范 3.1.0/2026-01-31、Solace 2.3.0、Pulsar 2.6.0、ROS 2 3.1.0）
- ✅ 新建 02-48 契约设计工作流与事件 API 治理（02 系列设计层）：契约先行 vs 实现先行、六步工作流+RACI、版本治理与删除公告期、与 02-12~46 模式的契约表达衔接、契约-Schema Registry 双门禁
- ✅ config-templates 新增 3 项：asyncapi-kafka-example.yaml、asyncapi-mqtt-example.yaml、spectral-asyncapi-ruleset.yaml
- ✅ examples 新增 asyncapi-generated-producer-example.py（Modelina 生成风格模型 + 手工横切逻辑对照，py_compile 通过）
- ✅ 四件套同步：INDEX/PROJECT_STATUS 统计更新（415 文件）、ROADMAP 批次14 勾记

## [3.4.0] - 2026-11-17

### 批次13：首批 Agent Skills 制作 + 批次编排确认

**首批技能（skills/ 目录，7 个，串行制作）**：
- ✅ `mq-selection`（选型论证）：SKILL.md + 决策树/选型矩阵 references 切片（源 01-03/01-19/01-20）
- ✅ `mq-doc-lint`（治理自检）：薄封装脚本挂接 topics/scripts/doc-self-check.sh
- ✅ `mq-ops-kafka-upgrade`（升级操作）：含 version-facts 时效切片 + 预检脚本
- ✅ `mq-pattern-dlq` / `mq-ops-dlq`（DLQ 论证/操作互链对）：含六系统对比切片与 redrive 骨架
- ✅ `mq-mqtt-deep-dive` / `mq-nats-deep-dive`（系统顾问）：5.0 特性与 JetStream 事实切片
- ✅ 验收：frontmatter/目录名/预算 7/7 过；`doc-self-check.sh --skill-drift` 对账通过（并修复其多行 source-doc 解析缺陷）；技能登记表入 AI_Skill/README

**批次编排确认（写入 ROADMAP 批次13~19）**：技能 → AsyncAPI 专批 → 版本基线 → 严谨性两半 → 深度补齐 → 结构治理；WARN 随批顺手修。

## [3.3.0] - 2026-11-17

### AI 技能体系与测试验证体系（第六阶段 · 批次12）

**AI_Skill 技能体系（对齐国际开放标准）**：

- ✅ 新建 topics/AI_Skill/ 系列 5 篇 + README：国际 Agent Skills 标准与生态对齐（核实至 2026-11：2025-12-18 开放规范、2026-10-22 捐赠 AAIF、70+ 平台）、项目主题技能图谱（六技能域 + 国际子主题对齐矩阵）、技能制作规范（AGENTS.md 扩展 + 安全红线）、模板与模型（3 模板 + 3 成品样例）、用例与用法（6 标准用例 + 评估方法）

**Testing 测试验证体系**：

- ✅ 新建 topics/Testing/ 系列 6 篇 + README：五层测试策略与权威锚点（Jepsen/TLA+/Testcontainers/Toxiproxy/Chaos Mesh，引用而非自造）、部署用例 TC-DEP-01~16、集成用例 TC-INT-01~12、集群用例 TC-CLU-01~10、失败纠正与修正机制（P/T/E/D/B 分类学 + 隔离降级 + 文档-测试同步修正）、自我验证机制说明

**自我验证机制（P4 提前落地）**：

- ✅ 新建 topics/scripts/doc-self-check.sh：规范自检三模式（quick/full/--skill-drift），覆盖禁用表述/归档引用/死链/定位声明/INDEX 登记/密度/技能漂移；2026-11-17 自检 ERROR=0
- ✅ 新建 topics/scripts/mq-smoke-test.sh：六系统容器冒烟（kafka/nats/rabbitmq/redis/mqtt/pulsar/all），trap 保证清理，无 Docker 自动 SKIP

**存量合规修复**：

- ✅ 02/03 系列存量 58 篇补齐"本文档定位"声明（硬性分工合规，自检强制）
- ✅ 元数据四件套同步：INDEX（新增两系列登记 + 统计 410）、PROJECT_STATUS（156 主题文档 + 质量保证更新）、ROADMAP（P5 批次12 + P4 检查脚本勾记）

**挂账（WARN，后续批次清偿）**：存量文档代码块语言标注约 120 处、部分文档"最后更新"日期缺失——见 doc-self-check.sh full 输出。

## [3.2.0] - 2026-01-06

### 前沿对齐与规范体系（第六阶段 · 批次5-9）

**P1 时效性对齐**：

- ✅ 新增 01-25 Kafka 4.0 专章（ZooKeeper 移除、KIP-848、KIP-932 Share Groups）；修正 01-13 KRaft 时间线事实错误
- ✅ 01-12 Pulsar 新增 4.x/Oxia 章节；01-15 RabbitMQ 新增 4.x 章节（mirroring 移除、quorum 默认化）；01-17 Redis 扩充至 219 行（Redis 8/AGPLv3）
- ✅ 新建 01-26 NATS 2.x 专章、01-27 RocketMQ 5.x 专章、01-28 Redpanda 专章、01-29 S3 解耦存储分析（WarpStream/AutoMQ/Tableflow）

**P2 前沿主题补章**：

- ✅ 新建 01-30 事件互操作标准（CloudEvents/AsyncAPI/OpenMessaging/AMQP 1.0）
- ✅ 新建 01-31 数据集成与流处理生态（CDC/Debezium、Kafka Connect、Iceberg/Tableflow 湖仓、Flink/流数据库）
- ✅ 新建 02-47 企业集成模式与事务消息模式（EIP 对齐、Outbox/Inbox/Saga）

**P0 骨架充实**：

- ✅ 03-39~03-62 共 24 篇骨架文档全部充实至中等密度（24/24 验收达标）

**规范体系建立**：

- ✅ 新建 AGENTS.md 协作宪法（密度标准、三级置信标注、治理规则、代理协作协议）
- ✅ 新建 TEMPLATES.md 文档模板（专章/02 设计/03 运维三套模板 + 引用速查）
- ✅ CONTRIBUTING.md 对齐规范体系；GLOSSARY 新增 Share Group 词条

## [3.1.0] - 2026-01-06

### 治理与对齐（第六阶段 · 批次1）

- ✅ 顶层 README 修正：三大系统 → 六大系统（补 Pulsar/RabbitMQ/Redis Stream），补录 concept05/06，02/03 系列描述补全，新增第六阶段说明
- ✅ INDEX.md 补全 88 个缺失索引条目（02-07~02-46 共40篇、03-15~03-62 共48篇），统计真实化（392 文件 / 137 主题文档 / 完成度诚实口径约80%）
- ✅ PROJECT_STATUS.md 全量重写：消除内部矛盾（原 555 总计 vs 4 配置模板等），实地核实数字，新增诚实完成度评估
- ✅ 合并归档 8 个冗余完成度报告（COMPLETION_REPORT*、FINAL_*、PROJECT_COMPLETION_*、IMPLEMENTATION_STATUS_FINAL），状态归一于 PROJECT_STATUS.md
- ✅ 新建 ROADMAP.md：P0–P4 四波任务清单 + 各系统版本追踪基线
- ✅ 全文引用修复：清理对已归档文档的全部死链（INDEX/topics README/README_FIRST/顶层 README）
- ✅ 本 CHANGELOG 语义化重排

## [3.0.0] - 2026-01-06

### 全面扩充（主题文档 38 → 137）

- ✅ 02-场景驱动架构设计：新增 02-07~02-46 共 40 篇（更多案例、混合架构、高可用、一致性保障 + 35 个消息专项设计模式：路由/顺序/去重/压缩/重试/死信/过滤/优先级/批处理/事务/流控/追踪/延迟/幂等/序列化/分区/存储/监控/安全/聚合拆分/转换适配/桥接/版本兼容/缓存/限流/降级/告警/调优/容量/灾备/测试/成本/自动化运维/数据治理）
- ✅ 03-架构与运维实践：新增 03-15~03-62 共 48 篇（迁移/安全加固/基准测试/成本/演练/容量/灾备/测试/预防 + 专项指南 + 24 个消息运维实践指南）
- ✅ 配置模板：扩展至 58 个（服务器/客户端/专项配置 + Prometheus/Grafana ×3 系统 + Docker Compose ×4）
- ✅ 运维脚本：扩展至 108 个（部署/巡检/演练/安全审计/治理检查/40+ 专项测试脚本）
- ✅ 01 系列补强：01-18~01-24（性能基准对比/选型矩阵/速查表/参考卡片/FAQ/术语表/学习路径）

## [2.0.0] - 2025-12-31

### 深度扩展（五大改进批次）

- ✅ 新增六大系统深度分析：01-12 Pulsar、01-13 Kafka KRaft、01-14 安全性、01-15 RabbitMQ、01-16 MQTT 5.0、01-17 Redis Stream
- ✅ 新增 03-10 Kubernetes 部署实践、03-11 故障排查手册、03-12 云服务消息队列对比
- ✅ 代码示例扩展至 52 个（Python/Go/Rust/C++/C/Java 六语言）
- ✅ 基础配置模板（Kafka/NATS/RabbitMQ Server + 客户端）
- ✅ 更新核心参数矩阵、选型决策树、INDEX、QUICK_REFERENCE（加入 RabbitMQ/Redis Stream）

## [1.0.0] - 2025-12-31

### 初始构建

- ✅ concept/ 原始概念文档 6 篇（concept01~06）
- ✅ 01-基础概念与对比分析（01-01~01-11：概念矩阵/思维导图/决策图网/形式化证明框架/设计模式/架构深度分析/场景演进/权威数据/异常容错/系统控制/核心概念梳理）
- ✅ 02-场景驱动架构设计（02-01~02-06）
- ✅ 03-架构与运维实践（03-01~03-09，含 SRE/可观测性/动态运维/集群管理）
- ✅ 04-动态系统论与演化分析（04-01~04-05）
- ✅ 核心元文档与导航体系（INDEX/CROSS_REFERENCES/GLOSSARY/QUICK_REFERENCE/SUMMARY 等）

---

**维护规则**: 每次批次完成后在顶部添加新版本条目；禁止同日批量版本号膨胀；条目须描述"做了什么"而非"新增了几个文件"。
