# 更新日志（Changelog）

> **归并说明**: 2026-01-06 治理批次中，原 2.x–6.4.x 共 30+ 个版本（均标注 2025-12-31 同日、每个仅新增 1-2 个文件）已按语义归并为下述版本。历史细节见 Git 提交记录。
>
> **归档规则**:
>
> - 触发条件：CHANGELOG.md 单文件行数超过 400 行。
> - 归档对象：起始月份在 6 个月前的版本条目（按条目日期计算）。
> - 归档路径：`topics/archive/changelog/YYYY-MM.md`，YYYY-MM 为被归档条目的起始月份。
> - 原文指针：归档后在 CHANGELOG.md 对应位置保留一行指针，如 `> [3.x.x] 条目已归档至 topics/archive/changelog/2026-05.md`。
> - 当前状态：本次更新后文件未超过 400 行，暂不实际迁移；规则先行建立，超限时按本规则执行。

## [3.31.0] - 2026-11-18

### 批次121-123：Testing/08-运维行为测试——系统特性运维用例体系（用户纠偏落地）

**纠偏背景**：用户指出测试体系缺"系统特性运维测试"独立成系（非业务/非 API 契约）——07 矩阵的 4 个运维特性仅为粗粒度种子，03-68 行为档案从未全面用例化。用户确认口径：**含客户端运维行为**（再平衡期间生产/连接风暴/重连风暴/版本兼容），独立 08 目录。

**批次121 行为目录**：ops-behavior.tsv——7 类 22 项行为（故障 6/生命周期 4/资源 3/配置 3/恢复 2/限额 3/客户端运维 4）× 7 系统适用矩阵（含 JVM 系/Linux 通用等范围标注）；每项锚定 03-68/03-67 行为依据
**批次122 用例生成**：ops-gen.py 手工知识库（KB 逐格实义 GWT：如 Kafka 磁盘满→not accepting new data→清理自动恢复；RabbitMQ 内存 watermark→publisher 阻塞；Redis maxmemory+allkeys-lru→驱逐行为；MQTT 3.1.1/5.0 混连→协商）——**131 用例**，CLI/admin/metrics 语言无关断言面；registry OPS 域
**批次123 首跑就绪**：registry 825→956 行；与 GAME DAY 动作层/断言层关系声明入每用例；四件套同步

## [3.30.0] - 2026-11-18

### Phase C 全选落地：04 系第 8-10 篇 + 十链示例 + 图谱扩边（Phase A 用户暂缓）

- **C1 04 系列 7→10 篇**：04-08 多系统竞争演化博弈（博弈论转写 04-06：生态位博弈/Kafka 兼容囚徒困境收益矩阵/ESS 地位，Docker/OCI 对标）；04-09 技术采纳周期量化（四类代理指标局限/S 曲线陷阱/六系统阶段判定更新表——零编造数字）；04-10 反脆弱架构设计原理（健壮/弹性/反脆弱三层/三原则/Canary Topic/RTO 改善率）
- **C2 十链端到端示例**（topics/examples/chain01-10）：01-82 每条代表链的可运行骨架——binding 声明→客户端代码→部署映射三层对账点；断点#2/#3 补偿模式实例化；链#10 为 XLAN 对拍边
- **C3 图谱关系密度**：+6 证据文档节点（01-63/65/66/67/TEST-C2/Jepsen）+概念 documentedIn 边+场景→ASE validatedBy 边——155→161 节点/168→182 边
- 治理同步：INDEX/STATUS（04 系 10 篇，主题 266）/ROADMAP Phase C 勾记

## [3.29.0] - 2026-11-18

### 挂账清零批：RocketMQ 语义格补定 + 560 格 GWT 全量充实 + Kafka 4.4 镜像 + 场景自动映射

- **挂账#4 RocketMQ 语义格**：12 维度等级补定【论证】（亮点：延迟消息/事务消息/DLQ 重试链原生=●，per-message TTL 无=○）——560 用例中 RocketMQ 80 格从挂账骨架转为实义用例；TEST-C2/knowledge-graph 同步补边（kg judge 订单×RocketMQ 实测 SUPPORTED 5 概念）；版本事实核实入季度复核
- **挂账#1 GWT 全量充实**：matrix-enrich.py（112 格手工知识库：84 语义格+28 运维格，等级驱动文案）重写 535 骨架——每格实义 Given/When/Then+权威互链；生成器入库可重跑
- **挂账#3 Kafka 4.4 镜像**：fixtures compose cp-kafka:7.8.0 → **apache/kafka:4.4.0**（官方镜像，KIP-1191 Share Groups DLQ 解锁）；TC-KAFKA-*-DLQ 用例挂账标记移除
- **挂账#2 场景自动映射**：scenario-map.py（读 SEMANTICS.md x-semantics 声明×约定主系统→校验矩阵格存在→生成 场景映射.md）首跑 **OK 全格存在**
- 修复：RocketMQ 图谱边 2 条 dim id 对齐（delay/flow-control）

## [3.28.0] - 2026-11-18

### 批次117-120：Testing/07-集成矩阵——四维维度化用例库（系统×语言×特性×转换链）

**批次117 骨架+种子**：四维模型（systems 7/languages 5+运行时/features 16 三字母码/transforms 4 链）+ 用例模板 + **25 条种子**（3 手写标杆：KAFKA-GO-DLV[ASE-001]/KAFKA-GO-DLQ[KIP-1191 挂账]/NATS-GO-BCK[ASE-010 平台期] + 22 手工内容格）；矩阵等级如实标注（Redis/MQTT DLQ=应用层模式用例）；matrix-registry 唯一事实源
**批次118 批量展开**：535 格 dry-run 骨架（TEST-C2 矩阵等级驱动文案：●正例/◐配置正例/○模式用例/—反向用例）；**560 用例文件全覆盖**（7×5×16）；RocketMQ 语义格如实挂账
**批次119 harness 集成**：matrix-check.py（结构/枚举/ID 唯一/文件存在/matrix↔test-registry 双向同步）入 E0 第 3 步；test-harness.sh 增 --sys/--lang 过滤（KAFKA×GO 实测选中 16 例）；test-registry 825 行；MATRIX_CHECK 560/560 OK
**批次120 收口**：场景包→矩阵格映射关系入 07 README（全量自动化脚本挂账）；四件套同步

## [3.27.0] - 2026-11-18

### 批次111-116：concept 全量消化层 + DSL 地基 + 六维映射 + 用例全面扩展 + hermes 闭环（本轮"全面梳理"四诉求闭环）

**批次111 concept/ 全量消化层（逐篇全量消化）**：8 卷 2151 行——卷一 01-01~27/卷二 01-28~57/卷三 01-58~80/卷四 02-01~30/卷五 02-31~60/卷六 03-01~34/卷七 03-35~68/卷八 04+AI+Testing；257 篇逐篇四行卡（论点/证据+置信级/关联/易错）+8 张知识地图+卷尾速查表
**批次112 DSL-AsyncAPI 基础全谱系（"通用的基础的基础"）**：01-83 DSL 通论（DSL/GPL 分界/语言设计四要素/表达力层级=思维表征统一理论）；01-84 消息 DSL 通用模式全集（十二大模式+跨规范映射）；01-85 数据描述语言谱系（二十年演化/JSON Schema 2020-12 全语义/三强对照）；01-86 AsyncAPI 构件语义全书（8 语义陷阱集）
**批次113 六维映射矩阵**：01-82 系统×语言×框架×binding×生成器×配置 10 条端到端链 + 生成器支持矩阵（断点#1 binding 丢失实证）+ 5 断点分析 + 速查表 + XLAN 接口
**批次114 用例全面扩展**：ASE 断言 17→**89 条**（12 维度×6 系统 72 格矩阵驱动展开：native→正例/config→配置正例/app-level→模式用例/none→反向用例）；registry 284 行（+72 格用例 TC-SEM-xx-SYS）；tc-assert-check 白名单对齐图谱全名
**批次115 hermes 执行规划与问题闭环**：TEST-16（执行时刻表 nightly/weekly/pre-release/集中批 + P0-P2 优先级与资源预算 + 八步闭环 SOP + 三模板：问题报告单/修复审批单/复盘总结单 + cases 案例库回流机制）
**批次116 收口**：INDEX 登记 01-82~86；STATUS/ROADMAP/AGENTS.md 同步

## [3.26.0] - 2026-11-18

### 批次108完成+110：自检盲区修复收口 + MCP server MVP（知识库 AI 原生出口落地）

**批次108（完成态）**：doc-self-check 死链检查增 %20 URL 解码（105 实锤盲区修复）；Python 全库文件级普查 319 md 文件坏链 0（历史虚假链接清零验证）；计数口径闭合（主题 257=79+59+68+7+6+34+4；总计 641 含 results 产物说明）；Testing 根 3 运行文件评估保留（脚本路径耦合，已记录）
**批次110 MCP server MVP**：AI_Skills/mcp-server/（server.py 174 行 FastMCP stdio + requirements + README 112 行）——**7 只读 tools**（5 校验脚本 + kg 概念查询 + 场景×系统判定）+ **2 resources**（概念卡/文档片段，路径白名单硬编码防穿越，../AGENTS.md 实测拒绝）；参数白名单透传+超时+结构化错误；**未暴露任何修复/执行/混沌脚本**（L0-L3 只读纪律）；--dry-run 无依赖自检模式；批次 92 评估方案落地，TC-SKL 技能回放衔接说明入 README

**治理同步**：ROADMAP 108/110 勾记——**批次 106-110 全部闭环**

## [3.25.0] - 2026-11-18

### 批次106-109：concept 人类友好总集 + DSL 全链审计 + 图谱全量扩容

**批次106 concept/ 2.0（人类阅读层，用户确认"兼顾导览+内容"方案）**：README 三层表征总地图（人类/图解/机读）+ 三档阅读路径；00 论证标准导论（P3 标注/形式化资产/论证链四段式/认知偏差对策）；01 概念体系导读（108 概念按掌握依赖序六阶重构+10 易混概念对）；02 六系统论证链（五段式骨架×六系统）；03 场景论证链（8 场景走查+完整性自查）——5 文件 857 行，220 相对链接 os.path.exists 级全命中；**AGENTS.md concept/ 红线正式修订**（历史冻结→人类阅读层，事实源仍在 topics 防双源漂移）
**批次107 DSL-AsyncAPI 全链审计**：topics/DSL_ASYNCAPI_AUDIT.md 六环覆盖矩阵（L1-L3/L5-L6 部分/L4 完备）+ P0 补齐 dsl-schema.json（contract.yaml 正式 JSON Schema，8 场景全绿验证）+ contract-dsl-check.sh；**修复脚本 SERIES_DIR 残留旧路径**（contract 检查从 2 spec 恢复到 14 spec 覆盖）；登记 P1/P2 缺口清单（bindingVersion 缺失 13 处/外部 $ref 未解析/7 场景缺 quality-sla/无 design→asyncapi 生成器）
**批次109 图谱全量扩容**：graph.jsonld 25→**155 节点**（110 概念=01-58 全量/12 维度/8 系统 72 条能力边 degree 严格按 TEST-C2 ●◐○—/17 断言/8 场景），168 边全带 source；kg-query 新增 --path（BFS 最短路径）/--explain（判定依据含 degree+source）/--stats；跨域同名概念按域拆分节点保 108 全量入图

**治理同步**：INDEX 增 concept/ 总集段；STATUS（主题 253→257、总计 630→636 实测）；ROADMAP 批次 106-109 勾记

## [3.24.0] - 2026-11-18

### 批次94-105：五方向旗舰群 + Testing 体系统一重组（11+13 篇新章 + 结构治理）

**方向 1 技术运维画像（批次94）**：03-67 六系统运维画像矩阵（210 行，20+ 官方来源）；03-68 系统运行行为档案（270 行：启动序列/故障默认行为/资源线程模型/病态曲线图谱/K8s 探针）
**方向 2 消息技术设计（批次95/96）**：01-72 消息与数据编码对比矩阵（316 行 11 表：六系统大小限制实测参数/序列化全谱/压缩矩阵）；02-60 消息设计与演化策略（兼容性六分类/演化模式目录/治理门禁链）
**方向 3 动态控制（批次97）**：04-07 动态监测与控制回路（04 系第 7 篇：控制回路骨架/三类机制谱系/振荡四陷阱）
**方向 4 多语言深耕（批次98-100）**：01-73 Python（302 行）/01-74 TS-JS（307 行）/01-75 Go（326 行）/01-76 Rust+C（373 行）——28 个客户端版本全部带来源，维护风险如实标注（kafka-go KIP-896 不合规/kafkajs Issue #1603/sarama PR 积压/rumqttc RUSTSEC）；01-77 跨语言集成测试与 DSL 转换链（金样本对账法 + xlang-matrix.sh + TC-XLAN 6 条）
**方向 5 概念表征层（批次101-104）**：01-78 概念推理判定树（256 行）/01-79 UML 表示集（350 行）/01-80 场景领域转换决策树（252 行）；**knowledge-graph/ JSON-LD 机器图谱**（context+graph+rules 三文件，25 节点种子）+ kg-query.py 三态判定引擎（SUPPORTED/MISSING/CONFLICT，实测含蕴含闭包展开）**入 E0 第 8 步**；concept/README 迁移指针
**批次105 结构治理**：契约语义测试/ → **Testing/06-契约语义测试/**（git mv 保留历史）；TEST-13/14/15 → **TEST-C1/C2/C3** 消除撞号；**TEST-00 测试体系总规划**（六子目录职责+14 用例域全景+验证分层）；全库 26 文件路径修复 + 21 处死链精修（**暴露自检工具文件级检查盲区与 6 处历史虚假链接**——增强项列入批次 108）；E0 扩至八步

**治理同步**：INDEX 登记 14 新篇；STATUS（主题 238→253 实测、01 系 79/02 系 59/03 系 68/04 系 7/Testing 34 含 06 子系列 21、总计 630 实地核实——口径对账细化列入批次 108）；ROADMAP 批次 94-105 勾记；AGENTS.md 进度同步

## [3.23.0] - 2026-11-18

### 批次87-93：行业格局更新 + 流表一体/wire protocol 双旗舰 + CI 接入 + 04 深化 + 数据工厂

**批次87 行业格局更新（重大事实已核实）**：

- **[IBM 2026-03-17 完成 110 亿美元收购 Confluent](https://newsroom.ibm.com/2026-03-17-ibm-completes-acquisition-of-confluent,-making-real-time-data-the-engine-of-enterprise-ai-and-agents)** 落地四处：ROADMAP 版本追踪清单"行业格局事件"段（新增季度复核跟踪项）、01-25 生态格局注记、01-34 许可证影响专节（社区版条款/云转嫁/Apache 治理独立性三层影响）、01-28 Iceberg 时效注记
- 流表一体 GA 事实入版本清单：Confluent Tableflow GA（2025-03）、Redpanda Iceberg Topics GA（25.1，2025-04）

**批次88 流表一体专章**：01-70（261 行，15 个来源核实）：Kafka→Iceberg 五种形态全景（零拷贝视图 Streambased/broker 内建 Redpanda/托管表流 Tableflow/WarpStream Tableflow GA@2026-01/Aiven 单拷贝/AutoMQ Table Topic/Ursa）；**核实关键结论：Kafka 4.x 主线无原生 Iceberg 集成（官方 release notes 为据）**；schema→表契约演化规则与测试维度
**批次89 wire protocol 专章**：01-71（343 行）：ApiVersions 协商/RecordBatch v2/Produce-Fetch 全字段/fetch 会话（KIP-227）/事务报文序列 + **Jepsen KAFKA-17754 协议层解读（EndTxn 缺全局顺序约束）**；kcat（更名已核实）抓包实践
**批次90 CI/CD 接入**：`.githooks/pre-commit`（变更脚本 bash -n + registry 列数/ID 唯一 + 契约 spec 快速门禁）+ `.github/workflows/ci.yml`（E0 七步全量 on push/PR + nightly 任务包 dry-run + 产物归档）
**批次91 04 系列深化**：04-06 消息系统技术演化动力学（系列第 6 篇）：采用-生态增强回路、三组收敛对偶（队列×日志/本地×云/流×表）、重置事件表（含 IBM-Confluent）、niche→renewal 阶段模型
**批次92 学习路径与 MCP 出口**：LEARNING_PATH.md（三角色路径 × 国际权威教材：Kleppmann 免费书/EIP/Jepsen 等）；MCP_EXPORT_ASSESSMENT.md（KB→MCP server 映射评估，MVP 路线 C→B，实现待排期）
**批次93 测试数据工厂**：fixtures/generators/ 三生成器（订单 6 边界/支付 4 边界含负金额与非法币种/IoT 含时钟漂移与乱序），--validate 全过，字段对齐场景契约

**治理同步**：E0 七步终检（01-70/71 互链死链零容忍校验）；registry 212 行不变；STATUS（主题 235→238、01 系 68→70、04 系 5→6、元文档 18→20、总计 596→607 实地核实）

## [3.22.0] - 2026-11-18

### 批次77-86：国际对齐深化（ODCS/Microcks/Jepsen/混沌/AI契约）+ 抽象层与存储解耦专章

**批次77 欠账补齐**：TEST-13 用例漂移与更新机制（状态机 pending→mapped→verified/quarantined、三类漂移触发链、基准回灌流程）；TEST-14 skill 触发回放 21 用例（7 技能×正/边界/反例，registry SKL 域）
**批次79 ODCS v3.1.0 对齐**（Linux Foundation AI & Data 单一收敛标准，竞对 DCS 已弃用——已核实）：odcs-alignment.md 字段映射表（消息语义 vs 数据 SLA 边界【论证】）；01-order-lifecycle 增 quality/sla 范例段；contract-to-odcs.py 导出器（8 场景 --check 全过）
**批次80 Conformance 矩阵**：协议 TCK 清单（MQTT OASIS/AMQP ISO 19464/CloudEvents/Kafka）；**Jepsen 证据表（核实：Bufstream 0.1.0~0.1.3 于 2024-11，3 safety+2 liveness 全修复；核心发现 Kafka 事务协议 unsound 影响全 Kafka 兼容系统；Redpanda 2022-05 官方报告）**；自证资产证据等级规则
**批次85 安全与可观测**：sec-baseline-scan.sh（8 PASS/0 HIGH/6 WARN 真实缺口：redis TLS/kafka ACL 等）；SEC 域 20 用例注册；assertions.tsv 增至 17 条（+CloudEvents 信封/OTel trace 贯穿）
**批次86 AI 契约与治理**：ai-agent-contracts.md（A2A 任务生命周期/MCP 幂等/会话恢复 6 用例）；governance-tools.md（EventCatalog/asyncapi-diff/Spectral 三件套与漂移链合成）
**批次78 Microcks 集成**：docker-compose-microcks.yml + 06-行为验证/ 层（断言能力边界表：结构契约✅时序语义回退自研）；TC-CON-01/02 注册；dry-run 通过
**批次83 专章**：**01-67 存储解耦与队列化收敛**（四路线对比：KIP-405 内建分层/AutoMQ/Bufstream[Jepsen 证据]/WarpStream[Confluent 收购]；语义变化矩阵；share groups KIP-932 GA@4.2/KIP-1191 DLQ@4.4 已核实；12 维对照）
**批次84 专章**：**01-68 云原生抽象消息层评测**（Dapr pub/sub/Knative Eventing/Argo Events 十二维对照；Dapr 上游 conformance 复用方案；Microcks-Dapr 协作国际先例已核实）
**批次81/82 静态部**：Testing/06-混沌与故障注入/（三场景注入矩阵+game-day.sh dry-run）；TEST-15 动态系统论测试视角（04-03 方程可测化 DYN-A1~A3、回路→优先级映射、RTO 趋势表）
**注册表**：212 行（新增 SKL 21/SEC 20/AIG 6/CHA 3/DYN 4/CON 3/ABS 2）；registry 状态机首应用（TC-INT-09/10b/10c pending）
**治理同步**：STATUS（主题 235、01 系 68 篇、Testing 15 篇、契约语义测试 17 文档、总计 596 实地核实）；ROADMAP 批次 77-86 勾记 + 待办挂账（真实执行批：Microcks 首启/MQTT TCK/GAME DAY/TC-SEM 补全）

## [3.21.0] - 2026-11-18

### 批次64-76：hermes 执行底座 + 契约语义测试体系（顶层新系列，六层模型全链落地）

**批次64-65 hermes 执行底座（TEST-11 示意脚本实化 + E0 首跑）**：

- ✅ 五脚本落地：hermes-env-precheck（E0-E3 降级决策，实测本机 E0/E1/E2 可用 E3 缺 kubectl）/ hermes-diagnose（Git Bash netstat 回退）/ hermes-fix-l1（白名单+进程 Guard+七字段审计）/ hermes-collect-failbundle（T.11.5 结构）/ hermes-self-heal（L0-L3 分级，L3 只出审批单绝不自动修复）
- ✅ hermes-task-gen 任务包生成器（T.09.3 四项校验，违规退出码 2 实测）+ nightly/weekly/pre-release 三真实任务包
- ✅ hermes-e0-run E0 静态入口（产物五字段+日志尾三行正则严格满足 T.09.5）+ self-check-history.log + warn-ledger.tsv + .gitignore（results/ 不入库）
- ✅ E0 首跑 5/5 PASS（103 脚本 bash -n 全过）

**顶层主题文件夹 Testing/06-契约语义测试/（六层模型：DSL→AsyncAPI→绑定→语义→场景→用例）**：

- ✅ TEST-13 总纲：背景证据（registry 无 SEM/BUS 域）、六层定义、命名编号规范（TC-SEM/TC-BUS）、批次 71-76 映射、人在回路边界
- **批次71 契约静态层**：六系统 spec 集齐（新建 nats/amqp/pulsar/redis 四 spec；bindings 官方仓库逐一 WebSearch 核实——kafka 0.5.0/mqtt 0.2.0/amqp 0.3.0/nats·pulsar·redis 0.1.0）；contract-spec-check.sh（6/6 PASS）；contract-drift-check.sh（YAML 感知+绑定/x- 排除规则，DRIFT=0）；E0 增第 6 步
- **批次72 绑定矩阵**：bindings-matrix.md（四级字段覆盖矩阵+x- 扩展登记簿 x-jetstream/x-prefetch/x-pulsar-subscription/x-redis/x-semantics）；contract-binding-check.sh 22/22 PASS；**修正 mqtt 绑定层级违规 2 处**（qos/retain/expiryInterval 属 operation 级 per binding 0.2.0，config-templates 示例与 05-iot-telemetry 场景同步修正）
- **批次73 语义矩阵**：TEST-14（12 语义维度×6 系统能力矩阵，●◐○— 四级图例，论证引用 01-63~66 不重复论证）；assertions.tsv 机读 GWT 断言 14 条；registry 增 SEM 域 12 用例
- **批次74 业务场景库**：8 场景×3 文件（contract.yaml DSL + asyncapi.yaml + SEMANTICS.md 语义标注）；TEST-15 规范（消息三分/invariants 可测/评审清单）；TEST-12 加 T.12.8 互链节；registry 增 BUS 域 8 用例
- **批次66 dry-run 绑定**：test-harness E2 INT dry-run 11 例可解析；7 个引用脚本实地存在性核验；TC-INT-09/10b/10c 无脚本诚实转 pending
- **批次75 行为用例**：tc-assert-check.sh 父用例引擎（断言库 14 行+8 场景包结构 22 检全过）入 E0 第 7 步；TC-SEM-05（RabbitMQ DLX）/TC-SEM-07（NATS maxAckPending）样例脚本（--live 门禁，默认 dry-run）；registry 流转（BUS 8 mapped、SEM-05/07 mapped）
- **批次76 追溯闭环**：traceability.md 六层追溯表（登记口径覆盖 95%：L1→L2 10/10、L2→L3 6/6、L4→L5 8/8、L5→L6 10/20 含真实执行挂账 2/12）

**治理同步**：E0 扩至七步全绿；INDEX 登记新系列；STATUS（主题 213→226、主题 README 7→10、运维脚本→126、总计 508→578 实地核实）；ROADMAP 批次64-76 勾记；AGENTS.md 目录结构与新系列口径同步

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
