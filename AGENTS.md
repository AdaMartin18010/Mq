# AGENTS.md - 项目协作宪法

> 本文档是项目唯一的规范权威。所有文档编写、内容贡献、自动化代理协作均以本文档为准。
> 最近更新: 2026-01-06（第六阶段 · 治理与前沿对齐期间建立）

---

## 1. 项目定位

**消息队列全面分析论证知识库**（中文）：
对 Kafka、MQTT、NATS、Pulsar、RabbitMQ、Redis Stream 六大系统 + RocketMQ、Redpanda 等扩展系统进行多维度选型论证与运维实践参考，采用五种思维表征：概念矩阵、思维导图、决策图网、形式化证明、系统动力学。

**差异化资产**：04 系列动态系统论视角（因果回路图、故障传播方程、反脆弱分析）——国际 MQ 文档中罕见的独立视角，修改时须保留。

## 2. 目录结构与系列分工

```text
Mq/
├── AGENTS.md                 # 本文档（规范权威）
├── README.md                 # 项目门面（定位、导航、阶段状态）
├── concept/                  # 人类友好总集（2.0，批次106）：三层表征体系的人类阅读层——导览+精选重构+论证链；concept01~06 为历史资产；事实源仍在 topics/（防双源漂移）
├── Testing/                  # 测试验证体系：规范与计划/部署/集成/集群/可观测/体系与机制
├── Testing/06-契约语义测试/              # 契约与语义测试体系（2026-11-18 顶层化）：六层模型 DSL→AsyncAPI→绑定→语义→场景→用例
├── AI_Skills/                # AI 技能体系：5 篇规范文档 + skills/ 子目录 7 个 Agent Skills
└── topics/
    ├── 01-基础概念与对比分析/   # 29 篇：概念矩阵、专章分析（01-25~29 为 2026-01 新增前沿专章）
    ├── 02-场景驱动架构设计/     # 46 篇：场景化设计原理与选型论证（02-12~46 为消息专项设计模式）
    ├── 03-架构与运维实践/       # 62 篇：落地操作、配置、检查清单（03-39~62 与 02-23~46 一一对应）
    ├── 04-动态系统论与演化分析/ # 5 篇：系统动力学（项目特色，谨慎改动）
    ├── config-templates/       # 58 个生产配置模板
    ├── examples/               # 52 个多语言代码示例
    ├── scripts/                # 108 个运维脚本
    └── [元文档]                # INDEX/STATUS/ROADMAP/CHANGELOG/CONTRIBUTING/GLOSSARY 等 18 个
```

**02/03 分工约定（硬性）**：

- **02 系列 = 设计原理与选型论证**（为什么、选哪种方案）——每篇头部有定位声明，互链 03
- **03 系列 = 落地操作与检查清单**（怎么做、检查什么）——每篇头部有定位声明，互链 02
- 新文档必须遵守此分工，不得在一篇内混写两层

## 3. 文档编写规范

### 3.1 编号与结构

- 文件名：`XX-YY-主题名.md`；章节编号：`X.YY.Z`（如 01-25 → 1.25.1）
- 必须有：标题 → （可选定位声明）→ 目录 → 正文 → 参考来源 → `**最后更新**: YYYY-MM-DD`
- 目录必须与最终章节一致（改动正文后同步目录）

### 3.2 密度标准（主题文档）

| 类型 | 行数 | 代码块 | 表格 | 说明 |
| ------ | ------ | -------- | ------ | ------ |
| 深度分析/专章 | 250-400 | ≥4 | ≥3 | 如 01-12/01-25/01-27 |
| 运维/设计指南 | 180-290 | ≥2 | ≥1 | 如 02-12~46、03-39~62 |
| 速查/FAQ/参考卡 | 80-160 | 不限 | ≥1 | 如 01-19~01-24 |
| 骨架文档 | **禁止** | — | — | 纯提纲无示例的文档视为未完成 |

- 代码块必须标注语言（```bash/properties/java/yaml...），配置示例优先引用 `config-templates/` 中的真实参数
- 检查清单条目必须具体可勾选（含参数名/阈值/命令），禁止"检查配置正确性"式空泛项
- 例外：用例库/规划类文档（Testing 系列 TEST-02~04 等）不受 290 行上限约束，以用例完整覆盖为先，合理长度 180-400 行。

### 3.3 时效声明

涉及版本事实的文档（发布日期、KIP 状态、路线图）须在标题下加：

```markdown
> **时效声明**: 本文事实基于 X 官方发布信息，核实至 YYYY-MM。
```

版本基线见 ROADMAP.md 的"版本追踪清单"。

## 4. 引用与置信度规范（P3 体系）

### 4.1 三级置信标注

| 标注 | 含义 | 适用 |
| ------ | ------ | ------ |
| **【定理】** | 有严格数学证明或官方规范保证 | 协议语义（如 MQTT QoS2 恰好一次） |
| **【论证】** | 有官方文档/论文/基准支撑的工程推理 | 架构对比、容量估算方法 |
| **【估算】** | 工程经验值，无公开溯源 | 具体数字（如"重试放大系数 α≈0.3"） |

- 使用 ∀/∃/∫ 等符号的"形式化"内容：若无数理推导与机器验证支撑，必须标【论证】或【估算】，不得宣称"定理/证明"
- 定量声明（吞吐、延迟、成本、百分比）必须给来源链接；无法溯源的统一标注【估算】

### 4.3 知识权威宪章（2026-11-18 起）

本库作为 AI Agent 知识权威依据的治理规则（引用优先级/时效衰减/冲突闭环/背书/审计链/两轨分工）以 topics/KB_CHARTER.md 为总纲，K1-K6 族文件为准；本节不复制条款，冲突时以宪章族为准。

### 4.2 真实形式化资产（引用而非自造）

- Kafka KRaft 的 TLA+ 规范：apache/kafka 仓库 `metadata/src/main/resources/common/metadata/`
- Jepsen 评测：jepsen.io（Kafka、Redpanda、NATS JetStream 均有公开报告）
- 论文：Raft（Ongaro）、Paxos（Lamport）、BookKeeper

## 5. 元文档治理（一致性硬规则）

| 文档 | 角色 | 规则 |
| ------ | ------ | ------ |
| `PROJECT_STATUS.md` | **唯一权威状态** | 文件数、完成度只信此处；每次批次后更新 |
| `ROADMAP.md` | **唯一路线图** | P0-P4 波次任务 + 版本追踪基线；批次完成即勾 |
| `CHANGELOG.md` | 语义化版本记录 | 每次批次合入一个版本条目；**禁止同日版本号膨胀**；条目写"做了什么"而非"新增几个文件" |
| `INDEX.md` | 全量导航 | 新文档必须同步登记；统计数字与 STATUS 一致 |
| `SUMMARY.md` | 内容总结 | 保留，不再新建"最终总结"类文档 |
| `COMPREHENSIVE_REVIEW_AND_RECOMMENDATIONS.md` | 审查报告 | 历史档案 |

- **完成度诚实口径**：只报"约 X%"并附维度分解表，禁止宣称"100% 完成/生产就绪"
- 文件统计以 `find . -type f -not -path './.git/*' -not -path './.vscode/*'` 实地核实为准
- 已归档删除的文档（8 个完成报告）不得再被任何文档引用；新增元文档前先查 PROJECT_STATUS 清单防重复

## 6. 内容红线

1. **事实可溯源**：版本号、发布日期、KIP 状态必须经官方来源核实（WebSearch + 官方文档），禁止凭记忆写版本事实
2. **concept/ 与 topics/ 的分工（2026-11-18 修订，批次106）**：concept/ 是**人类阅读层**（导览/精选重构/论证链导航，兼顾实质内容与指针）；topics/ 是**事实源层**（完整定义/论证/细节专章）。concept/ 新增内容允许，但：概念定义/版本事实不得与 topics 双源——concept/ 内的事实性陈述必须带 topics 指针；topics 更新时 concept 相应导读节同步核对（随触及滚动）
3. **案例可溯源**：真实案例须给公开来源；"某银行/某电商"式合成案例必须标注「示意性合成案例」
4. **不造数据**：性能数字要么引官方基准，要么标【估算】，禁止编造"实测数据"

## 7. 当前进度与协作协议

### 7.1 阶段与批次（详见 ROADMAP.md）

- ✅ 批次1-11（P0-P4）：治理、骨架充实、时效更新、前沿补章、严谨性标注、持续机制（全部完成）
- ✅ 批次12-17（P5/P3 扩展）：技能体系、AsyncAPI 生态、版本基线、严谨性上半/下半（2026-11-17）
- ✅ 批次19-25：一致性治理、可观测专批、合规/AI/多活/血缘盲区批次（2026-11-17）
- ✅ 批次18（深度补齐）：02-07~09、03-15~38 共 27 篇加厚达标；01-23 术语充实；Testing 矩阵 RocketMQ/Redpanda ○→●（2026-11-18）
- ✅ 批次26（版本行动项落地）：版本追踪清单 7 组行动项全部落地（01-12/01-15/01-17/01-25/01-26/01-27/01-28 + 03-27，2026-11-18）
- ✅ 批次27-33（国际标准对齐）：AsyncAPI 组织级应用/EIP 全目录/云模式目录/应用层流协议/设计方法论与契约模板/工作流编排/JMS-AMQP，8 文档 + 3 模板（2026-11-18）
- ✅ 批次34-39（DSL 契约体系）：设计→DSL 转换/表达力边界与等价转换/Spec-Driven/IT 通用契约模式库/产业域与 IoT 互联网域消息标准，6 文档 + 3 模板（2026-11-18）
- ✅ 批次40-46（深度主题）：事件溯源+CQRS/Serverless/平台工程/零信任/OTel 语义/多云边缘联邦/客户端生态，8 文档（2026-11-18）
- ✅ 批次47（测试体系规划化）：TEST-08~10 三规划 + test-registry.tsv/test-harness.sh/doc-coverage-check.sh 三资产，执行移交本地 hermes（2026-11-18）
- ✅ 批次48-52（一致性/深度/前沿）：术语回灌 50 新词、02 系 28 篇+旗舰加厚、01-53~57 五新篇（2026-11-18）
- ✅ 批次53-58（重组+一致性基线+自治体系）：Testing/AI_Skills 顶层化、01-58 概念卡片/01-59 决策总树/表征更新/decision-check 机制化、7 技能审计清零、TEST-11/12+fixtures（2026-11-18）
- ✅ 批次59-63（批判修正+深度旗舰+实证+机制可持续化）：01-58 反例深化+275 行、二手→一手来源 9 条+04 织补 15 节点、01-60~01-66 旗舰七篇 500-700 行、03-66 基准实测指南+fixtures 模板、registry 20→60、CHANGELOG 归档规则+语义抽检（2026-11-18）
- ✅ 批次64-76（hermes 执行底座+契约语义测试六层体系）：hermes 七件套（预检/诊断/L1修复/failbundle/自愈/任务包生成/E0 入口）、E0 五步→七步全绿、顶层 Testing/06-契约语义测试/（TEST-13/14/15+六系统 spec+bindings 矩阵+x- 扩展登记簿+8 场景契约包+14 GWT 断言+SEM/BUS 注册 20 条+六层追溯表 95%）、mqtt 绑定层级违规修正 2 处、registry 151 行（2026-11-18）
- ✅ 批次77-86（国际对齐深化）：ODCS v3.1.0 对齐+导出器、Jepsen 证据矩阵、Microcks 06-行为验证层、SEC 基线扫描（6 WARN 缺口）、A2A/MCP 契约 6 用例、01-67 存储解耦与队列化/01-68 抽象消息层双专章、混沌与动态系统测试静态部、registry 212 行（2026-11-18）
- ✅ 批次87-93（行业格局与前沿）：IBM 收购 Confluent 影响落地 4 文档、01-70 流表一体（Kafka 4.x 无原生 Iceberg 结论核实）、01-71 wire protocol（Jepsen KAFKA-17754 解读）、pre-commit+CI、04-06 演化动力学、LEARNING_PATH+MCP 评估、测试数据工厂（2026-11-18）
- ✅ 批次94-105（五方向旗舰群+测试体系统一）：03-67/68 运维画像、01-72 编码矩阵、02-60 演化策略、04-07 控制回路、01-73~77 语言深耕群+跨语言集成、01-78/79/80 概念三表征、knowledge-graph+kg-query（E0 第 8 步）、Testing/06-契约语义测试 重组+TEST-C+TEST-00（2026-11-18）
- ✅ 批次106-109（concept总集+DSL审计+图谱扩容）：concept/ 2.0 人类阅读层（红线同步修订）、dsl-schema.json P0+全链六环审计、图谱 155 节点+kg-query --path/--explain/--stats（2026-11-18）
- ✅ 批次108+110（自检收口+MCP MVP）：doc-self-check %20 解码+全库普查坏链 0、AI_Skills/mcp-server FastMCP 7 只读 tools+2 resources（2026-11-18）
- ✅ 批次111-116（全量消化+地基+映射+用例扩展+闭环）：concept 8 卷 257 篇逐篇消化、01-83~86 地基+01-82 六维映射、ASE 89 条、TEST-16 三模板闭环（2026-11-18）
- ✅ 批次117-120（测试矩阵维度化）：Testing/07-集成矩阵 560 用例（7 系统×5 语言×16 特性全覆盖）+matrix-check 入 E0（2026-11-18）
- ✅ 挂账清零批（2026-11-18）：RocketMQ 12 语义格补定+560 格 GWT 全量充实（matrix-enrich.py 112 格知识库）+fixtures Kafka 4.4.0 镜像（KIP-1191 解锁）+scenario-map.py 场景映射（首跑 OK）
- ✅ Phase C 全选落地（2026-11-18）：04 系 8-10 篇（演化博弈/采纳量化/反脆弱）+examples 十链示例+图谱 161 节点 182 边——**Phase C 闭环；Phase A（真实执行集中批）用户暂缓随时可约**
- ✅ 批次121-123 系统特性运维测试（2026-11-18，用户纠偏）：Testing/08 独立成系——7 类 22 行为×7 系统适用矩阵+131 用例（KB 逐格实义 GWT，断言面 CLI/admin/metrics，含客户端运维行为口径）+OPS 域 registry 956 行——**测试三维齐备：语义（SEM）/业务（BUS）/系统行为（OPS）**
- ✅ 批次124-126 静态治理（2026-11-18）：TEST-17 整合对账（5 行状态纠偏+两代域动作/断言分工）+TEST-18 skill 回放 21/21 verified（首个 verified 域，4 处技能行为约束修复）+SEC 域 20 条 mapped（8P/0H/6W）
- ✅ 批次127 清欠批（2026-11-18）：Jepsen 证据回灌 01-63/01-59+SEC 6 缺口硬化（复扫 14/0/0）+E0 mapped 准入自动化（MAPPED_SCRIPT_CHECK）+AI_SKILL-04 行为约束三条款——**4 项挂账清零，项目进入维护态**（触发源=版本大更新/真实执行结果/用户新指令）
- ✅ 批次145 一致性总审计（2026-11-18）：consistency-audit.py 六层十维机器审计器常驻，12 项不一致清零复跑 0 项（总计 1679 全对齐）
- ✅ 批次146-151 概念体系 2.0（2026-11-18，回应"概念梳理敷衍无理论层次"批评）：五层理论塔+266 篇逐层归档/七大论证型+270 篇标注（定理上限仅 4 篇）/关系七型 10 机推规则/四模型族适用律/导读理论塔导航/kg rules 3→10+无环校验——concept/ 从读书笔记升格为**论证元理论**
- ✅ 批次152-157 AsyncAPI 纵深六批（2026-11-18，回应全面梳理批评）：构件本体+kg 173 节点/规范族六层符合性栈/转换规则全集/构件论证模板/技术栈全景 14 版本实测/契约设计规范 v1——AsyncAPI 域形成本体→符合性→转换→论证→工具→规范完整纵深
- ✅ 批次167 容器运行时 Docker→podman 迁移（2026-11-20）：RT shim（podman 首选+docker 回退+MQ_RUNTIME 覆盖）入 5 核心脚本（mq-smoke-test/microcks-compose/game-day/tc-sem-05/07）+3 层深死链修复×3（microcks ROOT、tc-sem-05/07 precheck）+E0 五脚本 cygpath 注入（YAML_PARSE_FAIL×14 修复，E0 九步 9/9 绿）+6 compose 适配（kafka healthcheck→kafka-cluster.sh 29092、mongo healthcheck→mongosh、microcks SPRING_MONGODB_URI 依 microcks/microcks#2053 定案、version 3.8 废弃行清除）+kafka 模板 Confluent ZK→KRaft 重写（apache/kafka:4.4.0 三节点，cp-kafka KRaft-only 实证，既有模板缺陷）+/opt/kafka/bin 全路径修正（镜像 PATH 缺陷）+冒烟 29092 INTERNAL 引导+240s KRaft 冷启窗口+rabbitmq messages_ready 兼容+quorum 收敛轮询+**T6 批量波 54 脚本 $RT 化**（128/128 bash -n 全绿、残留裸 docker 命令行 0）+端到端证据链（3-broker 全 healthy、Microcks health=200、H1 六轮冒烟终验 PASS=3/FAIL=0/SKIP=1[nats 宿主无 CLI 按设计]、game-day dry-run RC=0）+TEST-09/10/11/07 矩阵 README 四项运行时声明——**E1 podman 轨道为宿主默认，E2 docker 回退**
- ✅ 批次168 WIP 一致性收编+H2 销账（2026-11-20）：01-87~90 四页 TOC 子条目+表格空白（前一线机械残留）+HERMES-STATE 空白变更收编提交；H2 冒烟资产修复销账（批次167 六轮冒烟终验实证）
- ✅ 批次169 H1 A3 Microcks 契约测试收尾（2026-11-20）：compose 增 async-minion（官方 async-addon，config-templates_default 外部网络+depends_on service_healthy）+keycloak realm fixture（serviceaccount client_credentials）+4 业务场景 spec 自包含化导入（201，外部 $ref 本地内联；仓库文件仅 servers.host 改 INTERNAL 29092）+8 服务登记+minion 接线（Kafka bootstrap+keycloak.auth.url）+**6/6 场景契约测试全绿（9/9 用例 success，ASYNC_API_SCHEMA runner，filteredOperations 精确到操作级）**——根因链 4 项闭环：0 消费（minion latest 重置策略→`?startOffset=0`）/ messagePathPointer 校验失败（AsyncAPI 3.x operations 缺 `messages` 属性+payload 非标准 JSON Schema→补 messages+type 标准化，官方 v3 夹具实证）/ endpoint null NPE（1.15.0 TestRequestDTO 字段名 `testEndpoint` 非 endpoint，源码核实）/ 容器内端点 INTERNAL 29092（批次167 遗留）；证据 results/2026-11-20/h1-microcks-evidence.md（含可复用判据 4 条回灌）；三台账回写（HERMES-STATE H1 销账+RECOVERY H 表/队列 169 行+AGENTS 本行）
- ✅ H3 --live 真注入验证批（2026-11-21，用户在场授权门关闭）：`game-day-live.sh` v2 run-3 真注入 **6/6 PASS LIVE_RC=0**——TC-CHA-01 broker freeze 90s（pause kafka-1，producer 同冻=设计语义）/ TC-CHA-02 网络分区 125s（network disconnect，Leader 重选举 kafka-2/3 + catch-up 22s）；producer acks=all 退出 0、end offset==请求量 2100000/2000000（含在途零丢失）、ISR 3/3 恢复；run-2 2×A2 FAIL 根因=默认 delivery.timeout.ms=120s 注入窗口内 batch 到期丢弃（`Expiring 15 record(s)`，2046×15 精确吻合，broker 侧零丢失）+ run-1 残留 topic 污染（`already exists` 实证）→ v2 修=delivery.timeout.ms/max.block.ms=600s + watchdog 600s + topic 预清理；诚实边界=断言成立条件 delivery.timeout.ms>注入窗口+重选举时间（600s 覆盖 ≤5min）；TC-CHA-03 磁盘压力=WSL2 不可执行边界；证据=results/2026-11-21/h3-live-evidence-2026-11-21.md + 6 件 EVD（gitignored）；PROJECT_STATUS 1732 不变（find 实测零漂移）；CHANGELOG 3.53.0
- ✅ 批次198 文档内嵌代码块巡检入 E0 第十四步（2026-11-21）：`doc-codeblock-check.py`（语言标注 33 白名单 fail-closed+裸 fence WARN+bash 块逐块 bash -n[排除面 7 类实证登记]；--selftest 双向实证）；首扫抓真 bug=03-19 watch 单行引号惯用法缺引号已修（全仓 1348 md 语法全绿）；TEST-00 同步十四步；PROJECT_STATUS 1733→1734；E0 十四步全绿；CHANGELOG 3.55.0——**对称差 6 项全部补齐（L3 兑现+194-198），计划收官**
- ✅ 批次197 月度验收汇总落地（2026-11-21，L4 层，已推 `14e6aef`）：`monthly-acceptance.py [YYYY-MM]` 聚合 E0 history+nightly/weekly SUMMARY+registry 流转+ROADMAP 用户门（✅ 行自动剔除）→ `results/acceptance-YYYY-MM.md`；判定=周期覆盖率≥80%（连续两月<80% 升人审）；首月实报 11 月=8%（2/24，cron 批次176 才实装，诚实不通过）+ E0 当月 63 次 + verified=29 快照锚；TEST-16 时刻表增月末行；PROJECT_STATUS 1732→1733；CHANGELOG 3.54.0（注：3.53.0 为 H3 验证批，两批同日并行防膨胀重排）
- ✅ 批次196 动态验证脚本族落地（2026-11-21，已推 `3317d67`）：`dynamic-check.sh` 入口+4 子脚本（自愈预算模拟[lagThreshold=1000 排空 0.10s vs 预算 300s]/配置稳态巡检[5 WARN 登记:confluent ZK 遗留×2+latest×3]/契约边界复算[8 生成器双跑全等+探针在位]/技能动态自测[7 技能全可达]），全量 PASS <3min，对齐 BufferCache L2.5 会话层；排除面三次修正=墙钟字段/链式 hash 内嵌墙钟/blob://uuid 值；registry TC-DYN-05；PROJECT_STATUS 1727→1732；CHANGELOG 3.52.0
- ✅ 批次195 基准回归断言落地（2026-11-21，已推 `ba7e1f7`）：`Testing/benchmark/baselines.json`（L3 四锚点机读版：kafka 单机/联邦/nats RTT 两轮/rabbit e2e，approval 链入 _meta）+ `topics/scripts/bench-compare.sh`（--verify 静态自洽 + --run 快速回归[nats 速率/rabbit p50+零积压/kafka 容器内 exec perf 吞吐]，±30% 阈[kafka ±15%]，broker 不可达 SKIP 诚实口径）；实测=kafka 联邦 9993.0 vs 9998.0 PASS+nats/rabbit 宿主不可达 SKIP（WSL2 转发实证，容器已复原）；坑×2=MSYS_NO_PATHCONV 容器内路径改写（RC=127）、awk 函数内 shell 值内联转义反（除零）；入 nightly（TC-BENCH-001 --verify）+weekly（002-004 --run），registry BENCH 域 +4；PROJECT_STATUS 1725→1727；CHANGELOG 3.51.0
- ✅ 批次194 仓库机密泄露扫描门入 E0 第十三步（2026-11-21，已推 `f20cf0d`）：`secret-scan.sh`（7 类高信号形态：PEM 私钥头/AWS AKIA/GitHub ghp 系/Slack token+webhook/Google AIza/OpenAI sk-；git grep 跟踪文件面；**取舍**=通用 password 与 JWT 形态不收[占位值/格式示例必误报]；自测 fixture 生产排除；`--selftest` 双向实证 7/7 检出+全仓 0 命中）；**坑**=git grep `-` 开头模式被当选项解析（PEM 漏检）→ `-e` 显式定界（自测 6→7 全类）；TEST-00 E0 描述同步十三步；PROJECT_STATUS 1722→1725；E0 十三步全绿；CHANGELOG 3.50.0
- ✅ 批次193 队列收敛批（2026-11-21，已推 `20feae0`）：ROADMAP 新增"主控执行队列"单一视图区（收敛 HERMES-STATE/RECOVERY/L3 审批单/审计路线图 4 处入口为一表：H3 用户门/集中批余量/L3 已闭环/P2 触发/卫生核查/后续规划批）；卫生核查三项 no-op 留证（任务包日期戳=runner 只取文件名设计、孤儿 ZK 容器=已不在、kafka 栈在跑=191 留跑待 H3）；E0 复跑 12/12 RC=0
- ✅ 批次189 xlang --live 本机 5 语言全配对实跑闭环（2026-11-21，在途会话建 harness 后主控接管收口）：`Testing/xlang/` 新建（5 语言 JSON 客户端 project+emit 双模式 + `matrix_driver.py` 两相驱动[相1 参考分歧 repr/semantic 分类、相2 20 边 round-trip] + `ensure-lib.sh` jackson-core sha256 双钉定 + 构建产物 gitignore）；8 生成器钉 `random.seed(20261121)`=金样本可复现（数值字段双跑零差异实证；uuid 类 ID 不进 diff）；矩阵实跑 8 场景×20 有向边全 RC=0——相1 分歧 5 项：**inventory.quantity=semantic 唯一真分歧**（node/go 19 位奇数 10^18+7→10^18，JS Number/Go encoding/json float64 精度损失），余 4 项=repr 良性（整值 float .0 截断/Java 科学记数）；相2 差异 88 行=repr_drift 80+precision_loss 8，其余分类全 0；分类器改按规范值逐一核对（首版并集比较误判已修=陷阱账 23）；consistency-audit find 口径排除 xlang 构建产物（rs/target/.class/go 二进制/jar）；registry TC-XLAN-A1~A4/B1~B2 verified；审计文档 5 处过期声称回写+01-77 实跑期回写；PROJECT_STATUS 总计 1710→1722（find 实测）；E0 复跑 12/12 RC=0；CHANGELOG 3.46.0
- ✅ 批次172 H6 SEC 基线复扫（2026-11-20）：`sec-baseline-scan.sh` 复扫 **PASS=14/HIGH=0/WARN=0（RC=0）**，对照批次127 基线 14/0/0 零回退（14 项=传输加密 6/认证授权 4/审计网络面 3/K8s 部署面 1 全 PASS）；evidence-index.tsv 增量 +3 行（TC-SEM-MICROCKS-ASYNC@批次169 / TC-OPS-BEHAVIOR-DRYRUN@批次171 / TC-SEC-BASELINE@本批，随 verified 回灌）；证据 results/2026-11-20/h6-sec-rescan-evidence.md

- ✅ 批次173 H4 基准首跑+L3 审批单（2026-11-20）：Kafka producer 基线**官方 perf 工具容器内 exec 实测**（apache/kafka:4.4.0 自带工具，/opt/kafka/bin 全路径规避镜像 PATH 缺陷）：1KB/目标 10k msg/s/60s/acks=all/batch=16384/linger=10 → **稳态近 9.9k records/sec（9.70 MB/sec）**、p99=4ms/p99.9=89ms 量级（全窗口均摊 3287 records/sec 含 ramp-up/drain，稳态区间 9318~9931 为真实持续吞吐）；**拓扑缺陷发现**=kafka-1/2/3 实为 3 独立单节点（listener 全 localhost，容器间 9093/9094 不可达→健康检查 unhealthy，既有'3-broker'描述失实）→队列175 登记修复；NATS/RabbitMQ=blocked 诚实登记（容器未在跑+镜像无基准工具+宿主无 CLI）+解锁路径→队列176/177（L3 门）；L3 审批单已出 Testing/L3-审批单-H4基准转正-2026-11-20.md（A1 基线转正/A2 NATS/A3 RabbitMQ/A4 拓扑修复，用户门）；证据 results/2026-11-20/h4-benchmark-baseline.md（数值经 scratch 日志程序化提取，码点级复验）

- ✅ 批次174 H5 周期常态化（2026-11-20）：冒烟测试四系统全绿 **PASS=4 FAIL=0 SKIP=0 RC=0**（kafka/nats/rabbitmq/redis，单轮约 6 分钟，kafka KRaft 冷启约 3 分钟占主体）；四项修复：① 宿主 nats CLI 缺失→`go install` v0.5.2（C:/Users/luyan/go/bin，PATH 内）② nats 模板 compose 与 `nats:latest` 实为 **nats-server v2.15.3** 不兼容→每节点补 `--name`（server_name 硬要求）+`--cluster_name`（集群名硬要求；`-s`/`-c` 短形式实测无效=客户端标志/配置文件标志）③ nats 就绪等待 `sleep 3`→`nats stream ls` 轮询 60s 上限（三节点组建窗口）④ WSL2/podman 宿主端口转发对 rabbit mgmt HTTP 失效（TCP 握手成功但 Empty reply，三轮复现）→脚本 `rq()` 访问器=宿主 curl 优先+容器网络命名空间 curl sidecar 回退；副作用：长驻证据栈停止（自包含冒烟与长驻栈端口互斥，9092/4222/5672/15672）+**NATS 基准解锁**（批次173 队列176 前提已消，仍受 L3 审批门约束）；证据 results/2026-11-20/h5-smoke-normalization-evidence.md

- ✅ 批次175 队列175 Kafka 拓扑核查+healthcheck 修复（2026-11-20）：核查结论=**拓扑本身正常**（KRaft quorum=3 容器 DNS 互联；RF=3 全 3 分区 ISR=3 实证；网内 INTERNAL 引导集群视图 3 节点全 OK）→ 批次173 "3 独立单节点"描述**失实已更正**；真实缺陷=healthcheck 经 EXTERNAL（localhost:9092）引导时 AdminClient 将 2/3 节点解析到容器自身 localhost（9093/9094 仅宿主可达）→ api-versions ERROR → 3 节点 healthcheck 恒 unhealthy；修复=docker-compose-kafka.yml 三处 healthcheck 改 INTERNAL 引导（kafka-N:29092）+头部双监听语义注释；终验=重建栈 3/3 healthy + 冒烟 PASS（干净宿主）+宿主 9092/9093/9094 全 open；L3 审批单 A4 项标注已完成（联邦口径基线重采=后续可执行项随 A1）；证据 results/2026-11-20/q175-kafka-topology-evidence.md

### 7.2 AI 代理协作协议

> **执行分工（2026-11-18 起，K6）**：执行类工作（容器测试/周期任务/资产修复）移交 hermes 自治推进（队列见 topics/KB_DIVISION.md §2）；主控负责规划/治理/审计/知识梳理；用户负责背书与裁决。hermes 产物须经 results/ 佐证+registry 流转，主控抽审可回放。

1. **批次制**：按 ROADMAP 批次推进，每批次完成向用户汇报摘要，用户确认后进行下一批
2. **并行授权**：用户明确"可以并行"时，独立任务（不同文件）可启动多个子代理并行；同一文件禁止多代理同时写
3. **子代理规范**：派发任务时必须给出——目标文件路径、参考文件路径、密度标准（§3.2）、硬约束（不改其他文件、保留定位声明、日期规范）；子代理必须用 WebSearch 核实版本事实
4. **批次验收**：代理返回后按 §3.2 密度标准逐篇验证（行数/代码块/表格/定位声明/日期），不达标退回重做
5. **批次收尾四件套**：更新 INDEX.md 条目 → 更新 PROJECT_STATUS 统计 → 更新 ROADMAP 勾选 → CHANGELOG 加版本条目

### 7.3 用户审查

- 每批次 diff 摘要供审查；破坏性操作（删文件、合并）先列清单再执行
- 会话中断恢复时：先读 PROJECT_STATUS.md + ROADMAP.md 恢复上下文，不要凭记忆继续

---

**变更本文档时**：同步检查 CONTRIBUTING.md、PROJECT_STATUS.md、README.md 是否需要一致化更新。
