# 更新日志（Changelog）

> **归并说明**: 2026-01-06 治理批次中，原 2.x–6.4.x 共 30+ 个版本（均标注 2025-12-31 同日、每个仅新增 1-2 个文件）已按语义归并为下述版本。历史细节见 Git 提交记录。
>
> **归档规则**:
> - 触发条件：CHANGELOG.md 单文件行数超过 400 行。
> - 归档对象：起始月份在 6 个月前的版本条目（按条目日期计算）。
> - 归档路径：`topics/archive/changelog/YYYY-MM.md`，YYYY-MM 为被归档条目的起始月份。
> - 原文指针：归档后在 CHANGELOG.md 对应位置保留一行指针，如 `> [3.x.x] 条目已归档至 topics/archive/changelog/2026-05.md`。
> - 当前状态：本次更新后文件未超过 400 行，暂不实际迁移；规则先行建立，超限时按本规则执行。

## [3.20.0] - 2026-11-18

### 批次59-63：批判修正 + 前沿瞭望 + 深度旗舰六篇 + 实证能力 + 机制可持续化（上个会话中断批次原规格恢复执行）

**批次59 批判修正轮**：
- ✅ 59-A 概念一致性对账：01-58 概念卡片反例抽检深化（+275 行六元组反例）+ 01-19/20/21 与 01-59 决策总树口径对账修正
- ✅ 59-B 案例一手来源化：02-07/08/09 五处 factorhouse 二手综述改引官方一手工程博客（Robinhood/DoorDash/Netflix/LinkedIn 共 9 条一手 URL，核实可达）；1 处无一手来源（滴滴）保留并标注【二手综述】；04 动态系统论系列互链织补 15 节点/11 文件（每篇 04 被 ≥3 处回链）

**批次60 前沿瞭望**：01-60 前沿瞭望：2026-11 技术扫描（332 行六域扫描备忘录）

**批次61 深度旗舰工程（500-700 行旗舰六篇，全部 WebSearch 核实）**：
- ✅ 01-61 Kafka 存储与复制内幕（587 行：segment 格式/复制协议/Leader Epoch/KRaft 元数据日志/分层存储 KIP-405/调优/故障推演）
- ✅ 01-62 Pulsar 存算分离架构深度解析（656 行：Broker 无状态/BookKeeper 内幕/读写路径/Offload/Oxia/扩容再平衡；核实 Pulsar 5.0 GA 2026-10-05 为 LTS、Oxia 为推荐元数据）
- ✅ 01-63 Exactly-once 语义全论证（572 行：幂等生产者/Kafka 事务/KIP-98/129/447/890/流处理 EOS/语义边界/六系统对照）
- ✅ 01-64 MQTT-5.0 协议全解析（607 行：报文格式/会话状态机/QoS 时序/订阅选项/Reason Code 全表/增强认证/EMQX-Mosquitto-HiveMQ 现状）
- ✅ 01-65 死信队列完整工程解析（733 行）
- ✅ 01-66 背压机制全谱系（582 行：M/M/1 形式化/TCP-HTTP2-QUIC/Reactive Streams/六系统 broker 背压/Flink 反压/观测指标/决策树）

**批次62 实证能力**：03-66 性能基准实测指南（318 行：OpenMessaging Benchmark 实操/避免 Coordinated Omission/置信区间/六系统矩阵模板/结果回灌规范）+ Testing/fixtures/benchmark-result-template.md（114 行，SAMPLE 占位防误用）

**批次63 机制可持续化**：
- ✅ decision-registry.tsv 扩容 20→60（dec-021~060 覆盖前沿瞭望/Kafka 存储/Pulsar/EOS/MQTT/DLQ/背压/基准/决策树补全九域；doc-decision-check CONFLICTS=0 WARN=0）
- ✅ CHANGELOG 归档规则立规（超 400 行归档 6 个月前条目至 topics/archive/changelog/）+ topics/archive/README.md
- ✅ doc-semantic-spotcheck.sh 语义抽检机制（月度种子确定性抽样 6 篇：置信标注/时效/互链/章节一致性四查，只读）

**顺手修**：01-12 Pulsar 深度分析补互链段（语义抽检首跑唯一 FAIL 项闭环）；STATUS AI_Skills 分布行 5→6 篇口径修正
**治理同步**：INDEX 登记 8 新条目；STATUS 主题 205→213、01 系 59→66 篇、03 系 65→66 篇、脚本 114→115；ROADMAP 批次59-63 勾记

## [3.19.0] - 2026-11-18

### 批次53-58：顶层重组 + 思维表征一致性基线 + hermes 自治体系（用户确认全部，7 代理并行）

**批次53 顶层目录重组**：
- ✅ Testing/ 提升顶层（六子目录：00-规范与计划/01-部署用例/02-集成用例/03-集群用例/04-可观测用例/05-体系与机制 + fixtures 夹具层）
- ✅ AI_Skills/ 提升顶层（AI_SKILL-01~06 六文档 + skills/ 7 技能实体从根目录并入）
- ✅ 34 文件 git mv 保留历史；全库 42 处死链批量修复；doc-self-check 计数适配（Testing 两级 glob）

**批次54 概念一致性基线**：01-58 全局核心概念卡片总表（272 行，**108 个核心概念六元组**：定义/关键属性/关系/示例/实例/反例，10 域分组，反例列为特色）——全库概念唯一定义基线

**批次55 决策一致性基线**：01-59 全局选型决策总树（277 行，L0-L3 递归 28 节点，**全库选型判定唯一入口**+各专章决策树子树挂载规范）；14 项一致性核对表发现 4 项冲突（01-19 任务队列/微服务解耦口径陈旧等），01-19 已对齐 01-25/01-59 新口径

**批次56 思维表征更新**：01-02 思维导图重绘（355 行，全库 mermaid mindmap 纳入 27-58 全部新域 + 表征选型 6×6 指南）；01-03 决策图网+8 前沿决策节点（334 行）

**批次57 一致性机制化**：decision-registry.tsv（20 条判定注册）+ doc-decision-check.sh（注册表冲突检测/出处回查/概念卡片六元组完整性，实测 CONFLICTS=0 WARN=0）并入 doc-self-check quick 模式

**批次58 技能审计与自治体系**：
- ✅ 7 技能全合规审计（AI_SKILL-06 报告 198 行）：触发词补 35+ 覆盖新域，**漂移 WARN 15→0**；国际对齐 AAIF 生态（约 100 万 skills/2.8 亿安装，Anthropic 2026-10 捐赠核实）
- ✅ TEST-11 hermes 自治执行与自愈排障体系（259 行）：验证→诊断→修复→自愈→报告闭环、**自愈授权 L0-L3 白名单**、排障 runbook、自我修正流程
- ✅ TEST-12 企业应用场景端到端用例库（221 行）：电商订单全链路/金融转账/IoT 遥测三场景（与 TEST-03 技术维度互补）
- ✅ fixtures 夹具层：规范 README + 订单测试数据（含边界值）+ 三系统测试环境 compose 骨架

**治理同步**：INDEX 登记 6 条目；STATUS（主题 200→205、01 系 59 篇、Testing/AI_Skills 顶层口径、结构健康度 85→90%）；ROADMAP 批次53-58 勾记；终检 ERROR=0（WARN=4 历史档案知情项）

## [3.18.0] - 2026-11-18

### 批次48-52：一致性治理 + 深度加厚 + 国际前沿（用户确认"全部 5 批"，8 代理并行）

**批次48 一致性治理**：

- ✅ README 统计对齐（440→482 文件、162→195 主题、63→69 模板、111→112 脚本）
- ✅ 01-23 术语词汇表回灌 2026-11 批次约 50 个新术语（14 域：契约/模式/流协议/编排/领域标准/事件溯源/Serverless/安全/可观测/联邦/客户端/方法/AI），合并冗余旧行后精确 160 行
- ✅ GLOSSARY.md 同步回灌并修复 V/Z 区段重复
- ✅ AGENTS.md §3.2 增补用例库豁免条款（TEST-02~04 不受 290 上限约束）

**批次49 02 系列加厚 28 篇**（全部达 180-290 行，各补决策表+config-templates 真实配置引用+01 新专章互链）：

- ✅ 02-10~20（11 篇 218-261 行）、02-22~33（11 篇 244-290 行）、02-34~44（6 篇 235-259 行）；02-21 补事务选型决策表（170→186 行）

**批次50 旗舰+早期加厚**：

- ✅ 01-01 概念矩阵 140→258 行：8 维度×6 系统选型矩阵、决策场景速查、全库概念导航、四系统最小可运行示例
- ✅ 03-03/03-12/03-13/03-14 达 275-290 行（03-12 云服务对比 WebSearch 核实 MSK/Azure/GCP/Confluent 现状）
- ✅ 01-24 学习路径更新（纳入 01-25~52 与 02-47~59 新专章）

**批次51 国际前沿三篇**：

- ✅ 01-53 流处理引擎深度对比（372 行）：Kafka Streams（KIP-890 服务端防御）、Flink 2.3（ForSt/物化表）、Bytewax、Arroyo 0.15
- ✅ 01-54 流数据库（382 行）：RisingWave 2.6（Apache 2.0）、Materialize（BSL 1.1，4 年转 Apache）、ksqlDB（CCL）、Flink SQL 物化视图
- ✅ 01-55 数据契约与数据产品化（362 行）：三契约体系、dbt 契约、Great Expectations 1.25/Soda 3.5、数据网格四原则（Bitol/O'Reilly 权威来源）

**批次52 AI 深化两篇**：

- ✅ 01-56 AIOps 消息系统智能运维（277 行）：异常检测/容量预测/告警降噪、Confluent Intelligence（ML_DETECT_ANOMALIES_ROBUST）核实
- ✅ 01-57 AI-Agent 消息队列深化（296 行）：**MCP 已捐赠 Linux Foundation（2025-12-09），规范 2026-07-28 起 Streamable HTTP 替代 SSE**；Agent 任务队列+HITL 消息流

**治理同步**：INDEX 登记 5 新篇；STATUS（主题 195→200、01 系 52→57 篇、总计 482→487 实地核实）；ROADMAP 批次48-52 勾记；终检 ERROR=0（WARN=4 历史档案知情项）

## [3.17.0] - 2026-11-18

### 批次47：测试体系规划化（用户指令：Kimi 出规划/脚本/规范，执行移交本地 hermes，podman/docker/k8s 由 hermes 运行）

**规划文档三篇**（解决"文档分散、无系统化映射到测试用例"痛点）：

- ✅ **TEST-08 文档用例脚本映射矩阵与覆盖规划**（211 行）：文档层→用例层→脚本层三层资产模型、验证方式五分类、文档族→验证映射矩阵（18 族）、50+ 脚本↔用例映射（test/check 分类）、覆盖统计口径；识别 6 类缺口（04 动态系统论/01-25~29 前沿专章/AI_Skills/桥接流处理多活用例/元文档对账/模板断言）
- ✅ **TEST-09 测试执行计划与环境矩阵**（197 行）：E0（Git Bash 静态）/E1（Podman）/E2（Docker）/E3（K8s kind/k3s）四级环境矩阵、提交/夜间/每周/发布前四级频率、hermes YAML 任务包格式、环境缺失优雅降级为 SKIP、results/ 归档结构
- ✅ **TEST-10 用例编写与执行规范**（203 行）：TC-<域>-<NN> 编号规则、用例 Markdown 模板、脚本编写规范（严格模式/退出码 0=pass 1=fail 2=skip/末三行 RESULT+DURATION 输出）、四态判定与重试规则、执行率/通过率/缺口率公式

**基础执行资产三个**（hermes 直接可用）：

- ✅ **test-registry.tsv**（127 条）：74 个真实 TC 编号（TEST-02/03/04/07 提取）+ 50 个 CHK 巡检项 + 3 个 GAP 缺口（pending 状态）
- ✅ **test-harness.sh**：统一执行框架（--env/--domain/--id 过滤、--dry-run、超时控制、results/ 汇总报告、退出码约定），实测 CHK-018 PASS、GAP-04 正确 SKIP
- ✅ **doc-coverage-check.sh**：文档族覆盖检查，修正口径后实测 **61/64 族覆盖（95.3%）**，缺口正确显示（04 系列/AI_Skills/examples）

**治理同步**：INDEX 登记 TEST-08~10 + 尾部旧统计对齐（433→482 文件、158→195 主题、61→69 模板、110→112 脚本）；STATUS 同步；Testing/README 登记；修复代理产出 3 处死链；终检 ERROR=0

## [3.16.0] - 2026-11-18

### 批次40-46：深度主题补全（盲区扫描七域，用户确认"全部 7 批"，8 文档）

- ✅ **01-47 事件溯源核心机制与存储选型**（275 行，批次40）：事件存储/快照/投影/Upcaster；**EventStoreDB 已更名 KurrentDB（26.2，2026-09-30）**、Kafka 作事件存储边界、PostgreSQL 18/Redis 8.10 选型
- ✅ **02-58 CQRS 与事件溯源落地设计**（192 行，批次40）：读模型延迟治理、读己之写、Outbox/Saga 衔接、何时不用决策表
- ✅ **01-48 Serverless 事件架构与函数消息**（396 行，批次41）：Knative Eventing v1.24、Lambda SQS 批处理窗口/partial batch failure、Durable Functions、KEDA v2.21 函数 scaler、成本模型
- ✅ **02-59 消息平台工程与内部开发者门户**（246 行，批次42）：CNCF 平台工程成熟度五维模型、自助服务 L1-L4、Backstage（AsyncAPI 渲染/Spectral linter 插件）、EventCatalog 集成、Golden Path
- ✅ **01-49 消息系统零信任安全体系**（400 行，批次43）：KIP-768 OIDC（Kafka 3.1 内置）、MQTT 5.0 AUTH challenge-response、NATS nsc、SPIFFE/SPIRE、信封加密；**诚实口径：Kafka 官方发布仍用 GPG+SHA512（Strimzi 0.38+ 已用 Cosign）、无官方 SPIFFE 插件**
- ✅ **01-50 OpenTelemetry 消息语义约定与全链路追踪**（331 行，批次44）：**semconv v1.45.0 变更（messaging.system 废弃→messaging.system.name，kafka.* 命名空间迁移）**、六系统 traceparent 注入矩阵、批量消费 span 建模
- ✅ **01-51 多云与边缘消息联邦技术**（350 行，批次45）：MM2 exactly-once（3.5+）vs Cluster Linking vs NATS Supercluster；**uReplicator 已停滞**、eKuiper v2.4、NanoMQ CVE 警示
- ✅ **01-52 多语言客户端生态与编程模型**（374 行，批次46）：**sarama 维护放缓、franz-go 支持 0.8-4.4+**；Kafka 客户端-broker 双向兼容规则（4.x 需客户端 ≥2.1）；MicroProfile Reactive Messaging 3.0/Spring Cloud Stream 4.3/虚拟线程

**治理同步**：INDEX 登记 8 条目；STATUS 统计（主题文档 184→192、总计 468→476 实地核实）；ROADMAP 批次40-46 勾记；自检通过

## [3.15.0] - 2026-11-18

### 批次34-39：DSL 契约体系（用户确认"全部 6 批"，以 DSL 为主线：设计 → DSL → 治理 → 场景 → 领域）

**新增 6 篇主题文档**（全部版本事实 WebSearch 官方核实）：

- ✅ **01-43 设计到 DSL 的转换方法论**（395 行，批次34）：五源转换——Event Storming 色标→构件映射、EIP 模式三态映射（直接表达/需 x- 扩展/需下沉）、遗留代码逆向（Springwolf 2.9.0 为 2.x 最后版本、EventCatalog 插件 7.0.3）、OpenAPI→AsyncAPI 规则、BPMN→消息契约；每源 before/after 示例与反模式
- ✅ **01-44 DSL 表达力边界与等价转换策略**（379 行，批次35）：AsyncAPI 3.1 构件表达力清单、四类不可表达语义（行为逻辑/数据派生/非功能不完整/跨契约编排，绑定字段缺口经官方 binding 文档核实）、等价转换策略矩阵（x- 扩展/外部 $ref/多规范混合/下沉代码/平台配置）、"进 DSL 还是进代码"决策树、Smithy eventStream/TypeSpec Events/GraphQL subscription 对照
- ✅ **02-56 Spec-Driven 契约驱动开发体系**（268 行，批次36）：契约三范式对比、评审门禁（spectral:asyncapi + breaking change 政策 + 事件语义化版本）、漂移检测分级治理、生命周期四态状态机（联动事件目录）、契约测试金字塔（Microcks Incubating/Pact MessagePact）
- ✅ **02-57 IT 通用场景事件契约模式库**（260 行，批次37）：命令/事件/查询三契约、CDC（Debezium envelope 字段官方核实）、告警（CloudEvents）、审计、任务信封、Webhook 交付（CE HTTP Webhook 规范核实）六模式
- ✅ **01-45 产业领域消息标准纵览**（399 行，批次38）：金融 ISO 20022（SWIFT CBPR+ 2025-11 共存结束、Fedwire 2026-11-16 结构化地址强制）、医疗 FHIR R5 订阅（R6 草案中）、物流 EPCIS 2.0/CBV 2.0（2022-06 GS1 批准）、能源 OpenADR 3.0（2025-04 首批认证）；四步领域契约化共性模式
- ✅ **01-46 IoT 与互联网领域消息标准纵览**（382 行，批次39）：Sparkplug 3.0（Eclipse 规范）、OPC UA PubSub 1.05.06（OPC UA FX 2026-07 维护发布）、订单状态机事件建模、A2A v1.0.0 GA（2026-03-12）

**新增 config-templates 模板 3 个**（批次37）：cdc-debezium-event-template.yaml、task-envelope-template.yaml、webhook-delivery-template.yaml

**治理同步**：INDEX 登记 6 条目；STATUS 统计更新（主题文档 178→184、配置模板 66→69、总计 459→468 实地核实）；ROADMAP 批次34-39 勾记；01-43 超行精简（411→395）；AGENTS.md §7.1 更新

## [3.14.0] - 2026-11-18

### 批次27-33：国际标准对齐（用户确认"全部 7 批 + 并行代理逐批推进"，补齐 AsyncAPI 全面应用与设计模板等 7 大域盲区）

**新增 8 篇主题文档**（全部版本事实 WebSearch 官方核实，时效声明核实至 2026-11）：

- ✅ **01-37 AsyncAPI 组织级应用与治理**（394 行，批次27）：Kafka/MQTT/NATS/SQS/Solace/JMS 绑定深度与坑表、事件目录平台对比（EventCatalog/Solace Event Portal/Confluent/Aiven Karapace/Backstage）、Microcks（已晋升 CNCF Incubating）契约测试 CI/CD、OpenAPI 协同、Solace 引 Gartner EDA 成熟度五级、Raiffeisen/LEGO/BNZ 采用案例
- ✅ **01-38 企业集成模式全目录与系统映射**（333 行，批次28）：Hohpe EIP 六大模式族 60+ 模式速查、逐模式映射项目 02/03 深度篇、六系统映射总表、选型决策树；与 02-47（Outbox/Inbox/Saga 深度）互链互补
- ✅ **01-39 云消息模式与微服务消息模式目录**（319 行，批次29）：Azure 11 个消息模式/AWS SNS-SQS-EventBridge（Bus/Pipes/Scheduler）-Kinesis/GCP Pub/Sub（ordering keys/exactly-once）核实、EIP 云化对应表、microservices.io 模式目录
- ✅ **01-40 应用层流协议与交互标准**（355 行，批次30）：WebSocket（RFC 6455/8441/9220）、SSE（WHATWG）、WebTransport（W3C CR 2026-07-30）、gRPC streaming、RSocket（W3C CG 2019 已关闭，生态活跃度低）、Reactive Streams 1.0.4（Reactor 3.8/RxJava 3/Akka 2.11）、六协议+MQ 选型总矩阵
- ✅ **02-53 事件驱动设计方法论与工作坊**（230 行，批次31）：Event Storming 三级流程与色标、Domain Storytelling、C4 建模、ADR 模板（含 Kafka 替代 RabbitMQ 示例）、DDD Context Mapping 与消息边界
- ✅ **02-54 事件契约模板库与命名规范**（225 行，批次31）：契约骨架五节结构、CloudEvents 信封适配、命名规范、错误事件契约、版本化与弃用模板
- ✅ **01-41 工作流编排系统与消息协同**（393 行，批次32）：Temporal v1.32.2/Camunda 8.10.0（BPMN 2.0.2，ISO/IEC 19510）/Open Workflow v1.1.0（原 CNCF Serverless Workflow 更名）/Dapr v1.19.1/Conductor（Netflix 2023-12 停维护，社区 fork conductor-oss）；编排 vs 编舞选型矩阵
- ✅ **01-42 JMS/AMQP 与传统企业消息标准**（386 行，批次33）：Jakarta Messaging 3.1（Jakarta EE 11 仍为 3.1，无 4.0——纠正原线索）、AMQP 1.0 深度（ISO/IEC 19464、link/credit 背压）、RabbitMQ 4.0 起 AMQP 1.0 原生默认、STOMP 1.2、遗留集成选型

**新增 config-templates 模板 3 个**（批次31）：event-contract-template.yaml、cloudevents-envelope-example.json、asyncapi-contract-skeleton.yaml

**治理同步**：INDEX 登记 8 条目；STATUS 统计更新（主题文档 170→178、配置模板 63→66、总计 448→459 实地核实）；ROADMAP 批次27-33 勾记；修复 01-38→01-39 一处预留链接；自检 ERROR=0（WARN=4 历史档案知情项）

## [3.13.0] - 2026-11-18

### 批次26：版本行动项落地（批次15 版本基线"差距与行动"7 组清零，7 路并行执行）

全部版本事实经 WebSearch 官方来源核实，涉时效声明文档同步更新至"核实至 2026-11"：

- ✅ **01-25 Kafka**（189→253 行）：新增 4.2（KIP-932 production-ready）/4.3（KIP-1274 等 6 项）/4.4（KIP-1191 DLQ 等 5 项）演进段、官方"最近三个 release"支持策略、4.x 版本选择速查；选型决策树与场景表新增 4.4+ DLQ 分支
- ✅ **01-12 Pulsar**（1427→326 行，精简冗余扩写）：**5.0 确认 GA（2026-10-05，官方定位新 LTS）**，重写 4.x/5.0 演进段与选型口径；Oxia 确认为新集群推荐元数据存储（Helm 默认），ZooKeeper 经 PIP-454 在线迁移；精简重复代码示例与对比表，保留三层架构/BookKeeper/分层存储核心论证
- ✅ **01-15 RabbitMQ**（748→367 行，精简）：升级路径硬约束（3.13/4.0/4.1 必须先迁 4.2 再向上，含 Khepri 蓝绿例外）、支持窗口时间线（4.4 至 2027-07、4.3 至 2027-01、4.2 已 EOL）、Erlang/OTP 版本要求矩阵、升级检查清单
- ✅ **01-26 NATS**：章节"2.10/2.11 演进"大改为"2.10~2.15 演进"，版本表扩全谱系（2.15 最新/2.14 维护中/2.13 跳过/2.12 与 2.11 EOL 含终版号）、支持策略与 API level 门控说明
- ✅ **01-27 RocketMQ**（→381 行）：版本表更新至 5.5.1（2026-08-20 当前最新）；5.5.0（2026-04-10）LiteTopic 从"路线图"转为已发布事实（RIP-83）；时效声明从 2026-01 更新至 2026-11
- ✅ **01-28 Redpanda**（→303 行）：CalVer 口径对齐（v26.x，旧 21-25.x 为语义化遗留）；v26.2 支持至 2027-07-28、GitHub releases 止于 26.2.2；**Shadowing 首发纠正为 25.3**（官方来源，26.x 为增强迭代）；25.3 起 Iceberg topic 破坏性 schema 变更警示
- ✅ **01-17 Redis**（→231 行）：新增 Valkey 对照段（9.x 主线，互链 01-34 不重复展开）
- ✅ **03-27 版本升级指南**（201→256 行）：新增 NATS/RabbitMQ/Redpanda 三系统"版本现状与硬约束"（升级路径、支持窗口、Erlang 要求、Iceberg 变更评估），版本兼容性矩阵新增 Redpanda 行

**治理同步**：ROADMAP 版本追踪清单"差距与行动"列 8 行全部标 ✅ 落地；STATUS 时效性 92→95%、总体 88→90%；自检 ERROR=0（WARN=4 历史档案知情项）

## [3.12.0] - 2026-11-18

### 批次18：深度补齐（用户编排确认"批次18 先行 + 允许并行子代理"，5 路并行执行）

**案例研究加厚（18a，达深度分析标准 250-400 行）**：

- ✅ 02-07 更多生产环境案例（103→344 行，13 代码块/8 表格）：4 个合成案例深化（容量估算、故障场景、mermaid 架构图）+ 3 个公开可溯源案例（Robinhood Kafka、阿里双十一 RocketMQ、滴滴 RocketMQ，附来源链接）
- ✅ 02-08 混合架构案例（104→317 行，10/6）：DoorDash RabbitMQ→Kafka+Flink Iguazu、Netflix Keystone/Data Mesh、滴滴双写双读迁移
- ✅ 02-09 性能优化案例（108→281 行，8/6）：DoorDash 生产者批处理、Sophotech RabbitMQ→NATS 延迟优化、LinkedIn TopicGC

**运维指南加厚（18b，03-15~38 共 24 篇全部达 180-290 行 / ≥2 代码块 / ≥1 表格）**：

- ✅ 03-15~23（9 篇，181-282 行）：迁移、安全加固、基准测试模板、成本优化、故障恢复演练、容量规划、灾难恢复、性能测试、故障预防——补具体命令、config-templates/scripts 真实引用、可勾选清单
- ✅ 03-24~31（8 篇，181-242 行）：最佳实践、监控告警、安全加固清单、版本升级、故障排查、性能调优、自动化运维、成本优化实践
- ✅ 03-32~38（7 篇，184-254 行）：安全审计、合规（互链 01-34）、数据治理、文档管理、知识库、CI/CD、多租户

**术语与测试矩阵（18c）**：

- ✅ 01-23 术语词汇表（140→159 行）：新增 12 术语（KIP-932 Share Groups、Oxia、S3 解耦、LiteTopic、CalVer、CloudEvents、AsyncAPI、Outbox/Saga/Inbox、KEDA、OpenTelemetry、Valkey），Share Group 标注更新为 4.2 GA
- ✅ Testing 覆盖矩阵 ○→●：TEST-02/03/04 新增 RocketMQ/Redpanda 用例 20 个（docker 官方镜像验证设计，诚实标注未实机运行）；RocketMQ 行 7/7 ●、Redpanda 行 7/7 ●（一致性列维持 Jepsen 锚点说明）

**治理同步**：

- ✅ 元文档状态对齐：AGENTS.md §7.1 进度表重写（消除批次8-11 滞后标记）；PROJECT_STATUS 完成度更新（核心深度 80→90%、结构健康度 60→85%、总体 85→88%）、"剩余工作"节重写为批次26+滚动项；ROADMAP P4 表版本追踪清单 ✔→✅、批次26 登记
- ✅ 自检：doc-self-check.sh quick ERROR=0（WARN=4 均为历史档案知情保留项）

## [3.11.0] - 2026-11-17

### 批次21~25：盲区扫描五批（用户确认"全部"后执行）

**批次21 合规与许可证**：

- ✅ 01-34 许可证与选型合规（251 行）：八系统许可证矩阵（Redis 三许可核实至 2026-11、Redpanda BSL、Confluent CCL）、AGPL/SSPL/RSAL/BSL 条款深度解读、五场景合规决策树、云托管转嫁、合规例行机制
- ✅ 02-50 消息数据合规设计（186 行）：删除权 vs 不可变日志四大折衷、crypto-shredding、传键不传值、方案对比与反模式

**批次22 AI 原生消息**：

- ✅ 01-35 MQ×AI Agent（251 行）：A2A（2025-04 Google，2026-04 已 150+ 组织）与 MCP 双层栈、Agent 消息五大模式、六系统适配度矩阵（核实至 2026-11）
- ✅ 01-36 事件驱动 RAG 与流式管道（247 行）：RAG 管道消息化、四类事件流式语义、索引新鲜度 SLO 分解

**批次23 多活与跨地域**：

- ✅ 02-51 多活消息架构设计（162 行）：环回/冲突/全局序三大难题、六系统多活对照（关键判断：开源无开箱全域双写）、单元化/GeoRep/CRDT/Supercluster 四模式
- ✅ 03-64 跨地域运维实践指南（171 行）：按系统落地命令、跨区监测四指标、演练切换与对账

**批次24 血缘与 FinOps**：

- ✅ 02-52 消息数据血缘设计（180 行）：三档精度、捕获方式对比、影响分析入 PR 工作流、腐化对账
- ✅ 03-65 成本归集实践指南（172 行）：三级成本标签、分摊采集操作、元/百万消息单位指标、闲置治理 30 天规则

**批次25 机制补全**：

- ✅ doc-self-check 新增检查 #11：外链健康巡检（full 模式，300 上限，仅 404/410 告警，403/超时跳过）
- ✅ TEST-06 新增 T.06.8 季度保鲜例行清单（版本基线/全量自检+外链/技能对账/内容抽样，四行式记录纪律）
- ✅ topics/README 新增 concept→topics 映射表（6 篇历史资产 → 全系列重构落点）
- ✅ 7 个 Agent Skills 结构回放 7/7（references 可达 0 缺失、预算内、触发词覆盖本域）；实机回放列入季度保鲜例行

- ✅ 四件套同步：INDEX 登记 8 新文档；STATUS 统计更新（170 主题文档、448 文件）；ROADMAP 批次21~25 勾记
- ✅ 外链巡检首跑实证：发现 28 处死链（LinkedIn 工程博客迁移、BookKeeper/Pulsar 文档改版、Fowler 文章迁移、微软 learn 迁移等），已全部替换为验证可达的官方链接（200 实测）；检查器修复 HEAD-404 假阳性（csrc.nist.gov 类站点拒 HEAD，GET 复核）

## [3.10.0] - 2026-11-17

### 批次19：全面一致性治理（用户指令"全面梳理达成本项目全面的一致"）

**统计口径对齐**：

- ✅ 根 README 项目统计从 410/156/20/52/58/110 对齐至 440/162/18/53/63/111（含 skills 与 concept）
- ✅ 脚本 README 补登记 alert-quality-check.sh

**格式一致性（WARN 挂账清零）**：

- ✅ 代码块语言标注 73→0：启发式批量标注（bash/yaml/json/java/python/go/mermaid/text 等）+ 17 文件 46 处图示散文块标 text；修复中途一次状态机缺陷（带语言开 fence 未计入状态）并凭 git HEAD 精确回退重建
- ✅ 缺"最后更新"日期 23→0（19 篇主题文档补记 + 4 个系列 README）
- ✅ fence 结构异常 5→0：修正 3 篇新文档关闭 fence 带语言（本批创作瑕疵自纠）；修复 04-05 历史缺闭合 fence（text 块未闭合+python 块关闭错位）
- ✅ 自检脚本修复：awk 多文件 fence 状态跨文件泄漏（FNR==1 重置）——计数从失真 270 归位

**结构治理核查**：

- ✅ 同目录重复文件：零（03-11/03-28 批次3 已合并定位；同名仅各目录 README，属正常）
- ✅ 最终自检：ERROR=0，WARN=4（全部为历史档案 COMPREHENSIVE_REVIEW 知情保留项，检查器按设计保留）

**遗留（诚实口径）**：批次18 深度补齐（02-07~09、03-15~38 加厚，27 篇）维持滚动进行。

## [3.9.0] - 2026-11-17

### 批次20（插入批）：可观测性与自治运维专批（用户指令补齐）

**覆盖缺口定位**：现有 03-02/03-05/03-07/03-25 与 02-39/02-45 分散覆盖，缺"四能力域体系化总览 + MQ 原生伸缩触发模型 + 自愈分级与护栏 + 自治能力测试用例"四块。

- ✅ 新建 01-33 可观测性与自治运维能力体系分析（251 行）：四大能力域闭环模型、六系统核心指标矩阵（黄金信号+语义指标）、告警分级与 SLO 燃尽多窗口规则、KEDA 触发模型、自愈 L0-L4 分级与场景矩阵、六系统完备性矩阵、成熟度自评
- ✅ 新建 02-49 自动伸缩与自愈架构设计（181 行）：扩容组合触发模型、缩容六判据、KEDA 触发器对照（Kafka/Pulsar/RabbitMQ/NATS/Redis）、自愈检测器误报控制、伸缩/自愈与消息语义交互表、选型决策树、评审清单
- ✅ 新建 03-63 可观测与自治运维实践指南（183 行）：exporter 落地、Prometheus 抓取样例、promtool/amtool 校验、抑制配置、KEDA 安装与标定、非 K8s 伸缩脚本思路、自愈 Runbook 五步表、审计日志格式、GAME DAY、指标异常速查、八项检查清单
- ✅ 新建 TEST-07 可观测与自治能力测试用例（185 行）：TC-OBS-01~12（指标完备性/时效/基数、告警链路/抑制/SLO 校准/质量周检、lag 伸缩正确性、自愈有效性与护栏负向用例、仪表板回归、阈值漂移），接入 TEST-01 门禁
- ✅ 新增资产：config-templates/prometheus-alert-rules.yml（六系统分级告警规则集）、keda-scaledobject-kafka.yaml（扩缩不对称参数预置）；scripts/alert-quality-check.sh（告警质量周检，bash -n 通过、无环境 SKIP 验证）
- ✅ 四件套同步：INDEX/Testing README/ROADMAP（插入批次20 行）/STATUS（440 文件统计）

## [3.8.0] - 2026-11-17

### 批次17：P3 严谨性收尾

- ✅ **案例可溯源化**：02-07 两案例（某银行/某电商）加「示意性合成案例」标注；04-02/04-03 两处把伪装成"真实案例"的合成叙述改标为「示意性合成案例」（AGENTS.md §6.3 红线修正）
- ✅ **形式化资产链接补全**：01-04（新增"形式化验证资产"节：KRaft TLA+ 路径、Jepsen 报告、Raft/Paxos 论文 + 版本锚定引用纪律）、01-13、04-03 参考来源补全
- ✅ **定量声明引用规范化**：01-08 旗舰基准篇逐条来源链接核查合规（LinkedIn/Confluent/EMQX/NATS 官方源）；全库未标注数字由批次16"置信口径"基线声明统一按【估算】理解，行内化随文档触及滚动升级
- ✅ P3 三任务（置信标注/引用规范化/形式化链接/案例溯源）全部完成，STATUS 论证严谨性 40% → 55%

## [3.7.0] - 2026-11-17

### 批次16a/16b：P3 严谨性——三级置信标注 retroactive

- ✅ **全库基线覆盖**：147 篇主题文档（01 系 32 + 02 系 48 + 03 系 62 + 04 系 5）标题下统一插入"置信口径"声明（协议语义=【定理】/工程推理=【论证】/未标注数字=【估算】）；AI_Skills/Testing 系列 11 篇此前已行内标注
- ✅ **旗舰篇行内重点标注**：01-01 核心参数矩阵（参考出处=【论证】/无量源=【估算】/协议行=【定理】）、01-18 基准对比表（量级【估算】+ 自测指引）
- ✅ 自检 ERROR=0；标注规则与 AGENTS.md §4.1 一致，存量数字在文档被触及升级时再逐条行内化（滚动机制）

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

**首批技能（AI_Skills/skills/ 目录，7 个，串行制作）**：

- ✅ `mq-selection`（选型论证）：SKILL.md + 决策树/选型矩阵 references 切片（源 01-03/01-19/01-20）
- ✅ `mq-doc-lint`（治理自检）：薄封装脚本挂接 topics/scripts/doc-self-check.sh
- ✅ `mq-ops-kafka-upgrade`（升级操作）：含 version-facts 时效切片 + 预检脚本
- ✅ `mq-pattern-dlq` / `mq-ops-dlq`（DLQ 论证/操作互链对）：含六系统对比切片与 redrive 骨架
- ✅ `mq-mqtt-deep-dive` / `mq-nats-deep-dive`（系统顾问）：5.0 特性与 JetStream 事实切片
- ✅ 验收：frontmatter/目录名/预算 7/7 过；`doc-self-check.sh --skill-drift` 对账通过（并修复其多行 source-doc 解析缺陷）；技能登记表入 AI_Skills/README

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
