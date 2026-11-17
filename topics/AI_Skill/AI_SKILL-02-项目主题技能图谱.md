# AIS.02 项目主题技能图谱

> **本文档定位**：将项目 01~04 系列知识资产映射为符合 Agent Skills 开放标准（AI_SKILL-01）的技能目录设计，并给出与国际 MQ 技能子主题的对齐矩阵与优先级路线。本目录只管技能化设计，不重写知识内容。

## 目录

- [AIS.02 项目主题技能图谱](#ais02-项目主题技能图谱)
  - [目录](#目录)
  - [AIS.02.1 映射方法论：资产 → 技能三层映射](#ais021-映射方法论资产--技能三层映射)
  - [AIS.02.2 技能总目录设计](#ais022-技能总目录设计)
  - [AIS.02.3 与国际子主题对齐矩阵](#ais023-与国际子主题对齐矩阵)
  - [AIS.02.4 制作优先级路线图](#ais024-制作优先级路线图)
  - [AIS.02.5 与项目文档体系的同步机制](#ais025-与项目文档体系的同步机制)
  - [AIS.02.6 参考来源](#ais026-参考来源)

---

## AIS.02.1 映射方法论：资产 → 技能三层映射

技能化不是"把文档改名"，而是把知识资产按"Agent 可执行任务"重新组织。本项目采用三层映射：

| 层级 | 内容 | 本项目资产 | 技能承载方式 |
| ------ | ------ | ----------- | -------------- |
| L1 知识资产层 | 权威知识本体（唯一事实来源） | `topics/01~04` 系列 145 篇、`config-templates/` 58 个、`examples/` 52 个、`scripts/` 108 个 | 不直接装入技能；被 references 引用 |
| L2 技能目录层 | 面向任务的技能清单与分工 | 本图谱（AIS.02.2） | 目录登记（每技能一行） |
| L3 子主题技能层 | 单个 SKILL.md + 附属文件 | `skills/` 目录（制作时创建） | SKILL.md 编排 + references/ + scripts/ |

三条映射原则：

1. **单职责原则**：一个技能只做一类任务。反例：把"Kafka 全部运维"做成一个技能——必然超预算且触发模糊。正例：拆为 `mq-kafka-upgrade`、`mq-kafka-capacity`、`mq-kafka-benchmark`。
2. **引用而非复制**：技能 references 中的文件是从项目文档派生的"任务视角切片"，必须标注 `metadata.source-doc` 与派生日期，源文档更新后按 AIS.02.5 同步。
3. **设计/运维分层映射 02/03 分工**：技能也分两类——"选型论证技能"（references 挂 02 系列设计文档切片）与"操作清单技能"（references 挂 03 系列清单切片），同一主题两类技能互链，与项目 02/03 一一对应关系（02-12~46 ↔ 03-39~62）保持一致。

映射判定流程（决定"一段知识该不该做成技能"）：

```text
候选知识段
  ├─ 是否常被反复询问/执行？ ─否→ 留在文档，不做技能
  ├─ 是否有明确的任务输入与完成定义？ ─否→ 留在文档，不做技能
  ├─ 能否在 500 行 SKILL.md 内完成编排（知识下沉 references）？ ─否→ 拆分为多个技能
  ├─ 是否与现有技能主题重叠？ ─是→ 合并进现有技能，扩其 references
  └─ 通过 → 登记 AIS.02.2 目录，进入 AIS.02.4 排队
```

常见反模式对照表：

| 反模式 | 症状 | 纠正 |
| -------- | ------ | ------ |
| 文档整体改名装技能 | SKILL.md > 500 行、无 references | 拆出任务编排与切片 |
| 技能即问答机 | description 只有"回答 XX 问题" | 补"何时用 + 触发关键词 + 完成定义" |
| 技能互相复制知识 | 同一参数表出现在多个技能 | 收敛到单一技能，其余引用相对路径 |
| 一次技能永久保鲜 | `derived-at` 早于源文档 mtime | doc-self-check.sh --skill-drift 对账重派生 |

```text
# 映射示意：02-17 死信队列设计 + 03-44/03-59 相关清单 → 两个互链技能
mq-dlq-design/                    # 选型论证类技能（回答"为什么/选哪种"）
├── SKILL.md                      # 触发：DLX/TTL/重试上限方案论证
└── references/
    ├── design-comparison.md      # 派生自 02-17（六系统 DLQ 机制对比切片）
    └── scenario-matrix.md        # 派生自 02-01 场景矩阵 DLQ 行

mq-dlq-operations/                # 操作清单类技能（回答"怎么做/查什么"）
├── SKILL.md                      # 触发：DLX 声明/监控/重投/清理
├── references/
│   └── runbook-checklist.md      # 派生自 03-44 与 03-59 检查清单切片
└── scripts/
    └── dlq-redrive.sh            # 复用 topics/scripts/dlq-monitor.sh
```

首批技能（P0/P1）落地后的 `skills/` 目录预期形态：

```text
skills/
├── mq-selection/                 # P0-a：选型论证
│   ├── SKILL.md
│   └── references/{decision-tree,selection-matrix}.md
├── mq-doc-lint/                  # P0-b：治理自检
│   ├── SKILL.md
│   └── scripts/doc-self-check.sh # 复制自 topics/scripts/ 并标注来源
├── mq-ops-kafka-upgrade/         # P1-a：Kafka 升级操作
│   ├── SKILL.md
│   ├── references/version-facts.md   # 含时效声明
│   └── scripts/preflight-check.sh
├── mq-pattern-dlq/               # P1-b：DLQ 论证
│   ├── SKILL.md
│   └── references/dlq-comparison.md
└── mq-ops-dlq/                   # P1-b：DLQ 操作
    ├── SKILL.md
    └── scripts/dlq-redrive.sh
```

## AIS.02.2 技能总目录设计

按"系统专章 / 场景选型 / 消息模式 / 运维任务 / 测试验证 / 知识治理"六个技能域组织，与项目系列一一挂钩：

| 技能域 | 技能清单（候选） | 映射来源 | 优先级 |
| -------- | ------------------ | ---------- | -------- |
| D1 系统专章 | `mq-kafka-deep-dive`、`mq-pulsar-deep-dive`、`mq-rabbitmq-deep-dive`、`mq-nats-deep-dive`、`mq-mqtt-deep-dive`、`mq-redis-stream-deep-dive`、`mq-rocketmq-deep-dive`、`mq-redpanda-deep-dive` | 01-12~01-29 | P1 |
| D2 场景选型 | `mq-selection`（总决策树）、`mq-scenario-iot`、`mq-scenario-logging`、`mq-scenario-microservice`、`mq-scenario-financial` | 01-03、01-19、01-20、02-01~02-02 | P0 |
| D3 消息模式 | `mq-pattern-routing`、`-ordering`、`-dedup`、`-compression`、`-retry`、`-dlq-design`、`-filtering`、`-priority`、`-batch`、`-transaction`、`-flow-control`、`-delay`、`-idempotency`、`-serialization`、`-partitioning`、`-storage`（设计类 16 个）+ 对应 `mq-ops-*`（操作类） | 02-12~02-47 ↔ 03-39~03-62 | P1 |
| D4 运维任务 | `mq-kafka-upgrade`、`mq-k8s-deploy`、`mq-backup-restore`、`mq-capacity-plan`、`mq-benchmark`、`mq-chaos-run`、`mq-security-audit`、`mq-cost-optimize` | 03-01~03-38 专项指南 + scripts/ | P1 |
| D5 测试验证 | `mq-test-deploy-cases`、`mq-test-integration-cases`、`mq-test-cluster-cases`、`mq-test-correction` | Testing/ 系列（TEST-01~06） | P1 |
| D6 知识治理 | `mq-doc-lint`（规范性自检）、`mq-index-sync`（索引同步）、`mq-glossary-check`（术语一致） | AGENTS.md §3/§5 + topics/scripts/doc-self-check.sh | P0 |

命名规则见 AI_SKILL-03：全部 `mq-` 前缀 + kebab-case，域内分层用第二段区分（`pattern`/`ops`/`test`）。

各域明细（技能名 / 核心触发词 / 主要源文档 / 预估优先级）：

| 技能名 | 触发词（摘） | 源文档 | 优先级 |
| -------- | -------------- | -------- | -------- |
| mq-selection | 选型、Kafka 还是 Pulsar、message broker selection | 01-03/01-19/01-20 | P0 |
| mq-doc-lint | 文档治理、规范检查、doc lint | AGENTS.md + TEST-06 | P0 |
| mq-kafka-deep-dive | Kafka 架构、KRaft、KIP-932、kafka deep dive | 01-13/01-25 | P1 |
| mq-nats-deep-dive | JetStream、KV、ObjectStore、nats deep dive | 01-26 | P1 |
| mq-mqtt-deep-dive | MQTT 5.0、QoS、共享订阅、mqtt deep dive | 01-16 | P1 |
| mq-pulsar-deep-dive | 存算分离、Oxia、tenant、pulsar deep dive | 01-12 | P1 |
| mq-rabbitmq-deep-dive | AMQP、exchange、quorum queue、rabbitmq | 01-15 | P1 |
| mq-redis-stream-deep-dive | XADD、XREADGROUP、redis stream | 01-17 | P1 |
| mq-rocketmq-deep-dive | NameServer、Proxy、事务消息、rocketmq | 01-27 | P2 |
| mq-redpanda-deep-dive | Seastar、内置 Raft、redpanda | 01-28 | P2 |
| mq-pattern-dlq | 死信、DLQ、dead letter、retry exhaustion | 02-17/03-44 | P1 |
| mq-ops-dlq | DLX 声明、重投、清理、dlq redrive | 03-44/03-59 | P1 |
| mq-ops-kafka-upgrade | Kafka 升级、rolling upgrade、版本回滚 | 03-27/01-25 | P1 |
| mq-k8s-deploy | K8s 部署、Helm、Operator、kubernetes kafka | 03-10 | P1 |
| mq-benchmark | 基准测试、压测、benchmark、perf test | 03-17/03-22 | P1 |
| mq-chaos-run | 混沌实验、故障注入、chaos | 03-19/04-04 | P2 |
| mq-security-audit | 安全审计、加固、security audit | 03-16/03-26/03-32 | P2 |
| mq-test-deploy-cases | 部署测试用例、TC-DEP | Testing/TEST-02 | P1 |
| mq-test-integration-cases | 集成测试用例、TC-INT | Testing/TEST-03 | P1 |
| mq-test-cluster-cases | 集群测试用例、TC-CLU | Testing/TEST-04 | P1 |

D3 消息模式技能与 02-12~46 的编号对应（设计类 `mq-pattern-*` 与操作类 `mq-ops-*` 成对制作）：

| 02 编号 | 主题 | 设计类技能 | 操作类技能 |
| --------- | ------ | ----------- | ----------- |
| 02-12 | 消息路由 | mq-pattern-routing | mq-ops-routing |
| 02-13 | 消息顺序 | mq-pattern-ordering | mq-ops-ordering |
| 02-14 | 消息去重 | mq-pattern-dedup | mq-ops-dedup |
| 02-15 | 消息压缩 | mq-pattern-compression | mq-ops-compression |
| 02-16 | 消息重试 | mq-pattern-retry | mq-ops-retry |
| 02-17 | 死信队列 | mq-pattern-dlq | mq-ops-dlq |
| 02-18 | 消息过滤 | mq-pattern-filtering | mq-ops-filtering |
| 02-19 | 消息优先级 | mq-pattern-priority | mq-ops-priority |
| 02-20 | 消息批处理 | mq-pattern-batch | mq-ops-batch |
| 02-21 | 消息事务 | mq-pattern-transaction | mq-ops-transaction |
| 02-22 | 消息流控 | mq-pattern-flow-control | mq-ops-flow-control |
| 02-23~46 | 追踪/延迟/幂等…治理 | mq-pattern-<名> | mq-ops-<名>（与 03-39~62 对应） |

制作节奏建议【估算】：每批次完成 4~6 对（设计+操作），约 6~8 个批次覆盖全部 36 模式；优先顺序按 03-59 测试用例暴露的问题频率调整。

**触发词设计**：每个技能的 description 必须同时覆盖"中文任务词 + 英文系统词 + 场景词"，例如 `mq-dlq-design` 的触发词集：死信/ Dead Letter / DLQ / 重试上限 / retry exhaustion / 消息堆积处理。这是 Agent 能否自动激活技能的关键（规范要求 description 含识别关键词）。触发词来源：真实用户提问日志（如有）> 02/03 文档标题与高频段落 > 同义词扩展；每技能触发词 ≥ 6 个，中英比例约 1:1。

## AIS.02.3 与国际子主题对齐矩阵

将本项目子主题与国际公开 MQ 技能生态（AI_SKILL-01 AIS.01.5）逐项对齐，定位"可直接对齐 / 需差异化补齐 / 空白领先"三类：

| 本项目子主题 | 国际对应技能/工具 | 对齐状态 | 本项目动作 |
| -------------- | ------------------- | ---------- | ----------- |
| Kafka 工程实践 | Lenses Kafka Skills + Kafka MCP server | 部分重叠 | 不重复造轮子；项目技能聚焦**中文语料 + 4.0/KIP-932 时效**（Lenses 技能以英文通用实践为主） |
| RabbitMQ 使用 | skillsdirectory RabbitMQ Skill（Grade A） | 重叠度高 | 引用对齐其 exchange/queue/binding 覆盖口径；项目差异点：4.x quorum 默认化时效（01-15） |
| 事件驱动架构（EDA） | mcpmarket Messaging & EDA Skill | 重叠 | 对齐其"消息层选型维度"（task hand-off/replay/backpressure，acemq 口径） |
| MQTT 5.0 专章 | 未见权威公开技能 | 空白 | 以 01-16/01-26 为源制作 `mq-mqtt-deep-dive`，占位国际空白 |
| NATS JetStream 专章 | 未见权威公开技能 | 空白 | 以 01-26 为源制作 `mq-nats-deep-dive` |
| Pulsar 存算分离 | 未见权威公开技能 | 空白 | 以 01-12 为源制作 `mq-pulsar-deep-dive` |
| Redis Stream | 未见权威公开技能 | 空白 | 以 01-17 为源制作 |
| RocketMQ / Redpanda / S3 解耦 | 未见权威公开技能 | 空白 | 以 01-27/01-28/01-29 为源制作 |
| MQ 作为 Agent 消息层 | acemq 对比分析（2026-10） | 对齐 | 02-34 桥接与集成设计吸收该对比口径 |
| 文档治理/自检 | 未见 MQ 领域公开同类技能 | 空白领先 | `mq-doc-lint` 依托 doc-self-check.sh 形成差异化资产 |

**结论【论证】**：国际生态在 Kafka/RabbitMQ/EDA 上已有可用技能，本项目对齐口径即可；真正稀缺的是 MQTT/NATS/Pulsar/Redis Stream/RocketMQ/Redpanda 的系统级技能与中文语料——这正是本项目 145 篇文档的差异化变现方向，优先制作（见 AIS.02.4）。

对齐状态的判定口径：

- **可直接对齐**：对方技能覆盖本项目同名子主题，且版本时效不冲突 → 制作时引用其口径并标注差异。
- **需差异化补齐**：主题重叠但语料/时效/深度不如本项目 → 以本项目文档为源制作，description 中标注差异化触发词。
- **空白领先**：国际无对应公开技能 → 直接以项目专章为源制作，并在交付说明中记录"国际空白项"，作为项目差异化证据。

矩阵维护规则：每季度按 AIS.01.5 的方法重查一次国际生态（新技能/新 MCP 服务器/安全研究更新），更新对齐状态列；发现"可直接对齐"项出现重大版本变更（如 Lenses 技能覆盖 Kafka 4.x）时，触发本项目对应技能的 references 对账（AIS.02.5）。

## AIS.02.4 制作优先级路线图

排序依据：差异化价值 × 使用频次 × 源文档成熟度。

| 批次 | 技能 | 理由 | 验收 |
| ------ | ------ | ------ | ------ |
| P0-a | `mq-selection` | 最高频任务；源文档 01-03/01-19/01-20 成熟 | 通过 AI_SKILL-03 评审清单 + AI_SKILL-05 用例 U1 回放 |
| P0-b | `mq-doc-lint` | 支撑本批次自我验证机制落地；脚本已存在 | doc-self-check.sh 全绿 |
| P1-a | `mq-kafka-upgrade` | Kafka 4.x 升级是 2025-2026 高频刚需；03-27 + 01-25 成熟 | 用例 U3 回放 |
| P1-b | `mq-dlq-design` / `mq-dlq-operations` | DLQ 是跨系统最高频模式；02-17/03-44 成熟 | 用例 U2 回放 |
| P1-c | `mq-mqtt-deep-dive`、`mq-nats-deep-dive` | 国际空白 + IoT/微服务高频 | 用例 U4 回放 |
| P2 | 其余 D1/D3/D4 技能 | 按源文档成熟度滚动制作 | 逐一经 TEST-06 自检 |

制作风险与缓解：

| 风险 | 信号 | 缓解 |
| ------ | ------ | ------ |
| 触发词过度重叠 | 两个技能同时被高频误激活 | 缩窄 description 场景词，必要时合并技能 |
| references 切片失真 | 对账时频繁发现语义偏离 | 切片改为"引用段落清单+原样摘录"，减少改写 |
| 源文档大改连锁失效 | --skill-drift 一次报 > 5 个技能 | 冻结新技能制作，先集中对账 |

每技能制作完成后必须：登记技能清单（下表格式，存于本目录 README）→ 附 source-doc 链接 → 跑 doc-self-check.sh → CHANGELOG 记条目。

技能登记表的表头格式（新增技能时复制一行）：

| 技能 | 域 | 版本 | source-doc | derived-at | last-verified | 状态 | 用例回放 |
|------|----|------|-----------|-----------|---------------|------|----------|
| mq-selection | D2 | 0.1.0 | 01-03/01-19/01-20 | - | - | 待制作 | U1 待回放 |

## AIS.02.5 与项目文档体系的同步机制

技能是派生物，源文档是唯一权威。防止"文档改了技能没改"的漂移：

| 机制 | 做法 | 责任方 |
| ------ | ------ | -------- |
| 溯源标注 | 每个 SKILL.md frontmatter 必含 `metadata.source-doc`（相对路径列表）与 `metadata.derived-at`（派生日期） | 技能作者 |
| 定期对账 | doc-self-check.sh 的 `--skill-drift` 模式：比对源文档 mtime 晚于 `derived-at` 的技能，输出待同步清单 | 脚本（TEST-06） |
| 时效声明继承 | 涉及版本事实的技能 references 必须带时效声明，日期不早于源文档 | 技能作者（AI_SKILL-03 强制） |
| 置信标注继承 | 【定理】/【论证】/【估算】标注随内容切片原样带入技能，禁止在技能化过程中"升级"置信级别 | 技能作者 |
| 失效下线 | 源文档被合并/归档时，对应技能登记 `metadata.status: stale` 并停止推荐使用 | 治理批次执行者 |

对账执行节奏与处置时限：

| 触发方式 | 执行者 | 处置时限 |
| ---------- | -------- | ---------- |
| 批次收尾（每个治理批次） | 批次执行代理 | 当批次内 |
| 源文档大改后（单篇 mtime 变更） | 文档修改者 | 3 天内或下批次 |
| `--skill-drift` 月度例行 | mq-doc-lint 技能 / 维护者 | 月度报告后 14 天 |

技能与源文档的版本对应关系建议用 `metadata.source-rev`（源文档 git 短哈希）记录，使每次对账可精确到版本而非仅日期——该项为可选项，在技能量 > 20 个后启用【估算】。

图谱维护职责：本图谱（AIS.02）由治理批次维护——每批次新增/变更技能登记后同步更新 AIS.02.2 目录与 AIS.02.4 路线；国际对齐矩阵（AIS.02.3）季度复核。图谱本身视同元文档，受 doc-self-check.sh 的 INDEX 登记与最后更新约束。

与 02/03 分工的一致性检查：技能化不改变 02（设计）/03（运维）的文档分工——设计论证进 `mq-pattern-*` 的 references，操作清单进 `mq-ops-*` 的 references；一篇 02 文档可同时被多个设计类技能切片引用，但切片之间不得互相矛盾（矛盾由对账时以源文档为准消解）。

```bash
# 示例：技能对账输出（示意）
$ ./topics/scripts/doc-self-check.sh --skill-drift
[WARN] skills/mq-kafka-upgrade: 源 01-25 更新于 2026-11-02 晚于派生日 2026-10-15，需同步
[OK]   skills/mq-selection: 4 个源文档均无更新
```

## AIS.02.6 参考来源

- [Agent Skills 开放规范](https://agentskills.io/specification)（frontmatter 约束、渐进披露预算）
- [Lenses Kafka Skills 发布博客](https://lenses.io/blog/introducing-kafka-skills-for-ai-engineering-agents)
- [RabbitMQ Skill（skillsdirectory）](https://www.skillsdirectory.com/skills/claude-dev-suite-rabbitmq)
- [Messaging & EDA Skill（mcpmarket）](https://mcpmarket.com/tools/skills/messaging-event-driven-architecture)
- [RabbitMQ vs Kafka vs NATS for AI Agents（acemq）](https://acemq.com/compare/message-brokers-for-ai-agents/)
- 项目内：[01-03 决策图网分析](../01-基础概念与对比分析/01-03-决策图网分析.md)、[01-19 选型决策矩阵](../01-基础概念与对比分析/01-19-选型决策矩阵.md)、[AGENTS.md](../../AGENTS.md) §2/§3/§5

---

**最后更新**: 2026-11-17
