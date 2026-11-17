# AIS.01 国际 Agent Skills 标准与生态对齐

> **本文档定位**：项目 AI 技能体系的标准基线——对齐国际 Agent Skills 开放标准与生态，所有版本事实均附来源链接。
>
> **时效声明**: 本文事实基于 Anthropic 官方发布、agentskills.io 规范及公开技术媒体报道核实至 2026-11。规范本身持续演进（2026-08 仍有字段级更新），引用前请复查 [agentskills.io/specification](https://agentskills.io/specification)。

## 目录

- [AIS.01 国际 Agent Skills 标准与生态对齐](#ais01-国际-agent-skills-标准与生态对齐)
  - [目录](#目录)
  - [AIS.01.1 标准演进时间线](#ais011-标准演进时间线)
  - [AIS.01.2 规范核心：目录结构、Frontmatter 与渐进披露](#ais012-规范核心目录结构frontmatter-与渐进披露)
    - [目录结构](#目录结构)
    - [Frontmatter 字段约束](#frontmatter-字段约束)
    - [name 与 description 的正误示例](#name-与-description-的正误示例)
    - [渐进披露（Progressive Disclosure）三层模型](#渐进披露progressive-disclosure三层模型)
  - [AIS.01.3 治理格局：AAIF 与三锚点项目](#ais013-治理格局aaif-与三锚点项目)
  - [AIS.01.4 采用者生态（多平台支持现状）](#ais014-采用者生态多平台支持现状)
  - [AIS.01.5 MQ 领域技能生态与安全研究](#ais015-mq-领域技能生态与安全研究)
    - [MQ 主题相关公开技能/工具](#mq-主题相关公开技能工具)
    - [技能供应链安全研究（必读）](#技能供应链安全研究必读)
    - [Skills 与 MCP 的分工（为什么 MQ 场景两者都需要）](#skills-与-mcp-的分工为什么-mq-场景两者都需要)
  - [AIS.01.6 对本项目的对齐含义](#ais016-对本项目的对齐含义)
  - [AIS.01.7 参考来源](#ais017-参考来源)

---

## AIS.01.1 标准演进时间线

Agent Skills 从 Claude Code 的功能发展为中立开放标准，关键节点如下（全部经公开来源核实）：

| 时间 | 事件 | 来源 |
| ------ | ------ | ------ |
| 2024-11 | Anthropic 发布 MCP（Model Context Protocol）并开源，成为 Agent 连接外部工具的事实协议 | [DataLLM Lab](https://www.datallmlab.com/blog/mcp-vs-skills.html) |
| 2025-10-16 | Anthropic 发布 Agent Skills（初始为 Claude Code / Claude Agent SDK 能力），`anthropics/skills` 仓库公开 | [innobu](https://www.innobu.com/en/articles/agent-skills-reality-check-study-2026.html) |
| 2025-12-09 | MCP 捐赠给新成立的 Agentic AI Foundation（AAIF，Linux 基金会 directed fund），创始成员含 Anthropic、Block、OpenAI，AWS/Google/Microsoft/Cloudflare/Bloomberg 支持 | [DataLLM Lab](https://www.datallmlab.com/blog/mcp-vs-skills.html) |
| 2025-12-18 | Anthropic 在 agentskills.io 发布 Agent Skills 开放规范与参考 SDK，邀请各厂商共建同一 SKILL.md 格式 | [Axis Future](https://www.jakecuth.com/work/claude-skills-lab/)、[NeuralCoreTech](https://neuralcoretech.com/agent-skills-open-standard-ai-agents/) |
| 2026-02 前后 | OpenAI Codex/ChatGPT 采用开放标准（"build on the open agent skills standard"）；GitHub Copilot/VS Code 直接读取项目内 SKILL.md | [bosio.digital](https://bosio.digital/articles/skills-vs-agents) |
| 2026-05 | VS Code / GitHub Copilot 稳定版支持；Cursor、Gemini CLI、Microsoft Copilot Studio 等 40+ 产品支持 | [Shingikai](https://shingik.ai/blog/substrate-architecture-strategy-three-layers-of-the-ai-council-stack-in-may-2026-and-where-the-moats-moved)、[MemoryPlugin](https://blog.memoryplugin.com/what-are-agent-skills/) |
| 2026-10-22 | Anthropic 将 Agent Skills 开放标准捐赠给 AAIF（与 MCP、AGENTS.md、goose 同治理）；官方称 70+ 平台已集成、约 100 万 skills 发布、近 2.8 亿次安装 | [Techmeme](https://www.techmeme.com/261022/p53)、[omidsaffari](https://omidsaffari.com/blog/agent-skills)、[Utopia Group](https://utopiagroup.com.my/ai-news/anthropic-donates-agent-skills-agentic-ai-foundation) |

**关键结论【论证】**：Agent Skills 的演进路径与 MCP 高度同构——先由 Anthropic 单厂发布，再以开放规范中立化，最终进入 Linux 基金会治理。这意味着 SKILL.md 格式在可预见的周期内具有跨厂商稳定性，本项目以其为技能化载体的选型风险低。

## AIS.01.2 规范核心：目录结构、Frontmatter 与渐进披露

以下字段与约束均直接取自 [agentskills.io 规范页](https://agentskills.io/specification)（2026-11-18 读取；规范页本身未标注发布日期，以现场读取为准），是技能制作的硬性约束。

### 目录结构

一个技能是一个目录，至少包含一个 `SKILL.md`：

```text
skill-name/
├── SKILL.md          # 必需：元数据 + 指令
├── scripts/          # 可选：可执行代码
├── references/       # 可选：补充文档
├── assets/           # 可选：模板、资源
└── ...               # 任意其他文件或目录
```

### Frontmatter 字段约束

| 字段 | 必填 | 约束（规范原文） |
| ------ | ------ | ------------------ |
| `name` | 是 | ≤64 字符；仅小写字母、数字、连字符；不得以连字符开头/结尾；不得含连续连字符；必须与父目录名一致 |
| `description` | 是 | ≤1024 字符、非空；描述技能做什么以及何时使用；应包含帮助 Agent 识别任务的特定关键词 |
| `license` | 否 | 许可证名称或捆绑许可证文件引用 |
| `compatibility` | 否 | ≤500 字符；声明环境要求（目标产品、系统依赖、网络访问） |
| `metadata` | 否 | 任意字符串键值映射，供客户端扩展 |
| `allowed-tools` | 否 | 空格分隔的预批准工具列表（实验性，各实现支持不一） |

### name 与 description 的正误示例

```yaml
# ✅ 合法 name
name: pdf-processing
name: code-review

# ❌ 非法 name（规范明确列为反例）
name: PDF-Processing   # 不允许大写
name: -pdf             # 不得以连字符开头
name: pdf--processing  # 不允许连续连字符

# ✅ 良好 description（做什么 + 何时用 + 触发关键词）
description: Extracts text and tables from PDF files, fills PDF forms, and merges
  multiple PDFs. Use when working with PDF documents or when the user mentions
  PDFs, forms, or document extraction.

# ❌ 不良 description
description: Helps with PDFs.
```

### 渐进披露（Progressive Disclosure）三层模型

规范定义了技能加载的三层预算，这是"为什么 SKILL.md 要短"的根本原因：

| 层级 | 内容 | 加载时机 | 预算 |
| ------ | ------ | ---------- | ------ |
| L1 元数据 | `name` + `description` | 启动时全部技能加载 | 每技能约 100 tokens |
| L2 指令 | `SKILL.md` 正文 | 技能被激活时 | 建议 < 5000 tokens；SKILL.md 保持 < 500 行 |
| L3 资源 | `scripts/`、`references/`、`assets/` 内文件 | 实际需要时按需读取 | 按需 |

规范同时要求：技能内引用其他文件使用相对路径且保持"一层深度"，避免深层引用链；官方提供参考实现校验器 `skills-ref`：

```bash
# 使用 skills-ref 校验技能（参考实现位于 github.com/agentskills/agentskills）
skills-ref validate ./my-skill
```

无 skills-ref 时的手工校验清单（项目 doc-self-check.sh --skill 模式已内置）：

```bash
# 手工校验四问
# 1. SKILL.md 第 1 行是否为 ---（frontmatter 必须起于文件头）
head -1 ./my-skill/SKILL.md
# 2. name 是否等于目录名，且满足字符约束
grep -E '^name:' ./my-skill/SKILL.md
# 3. description 是否存在且 ≤1024 字符
awk '/^description:/{f=1} f&&/^---/{exit} f' ./my-skill/SKILL.md | wc -c
# 4. 引用文件是否一层深度且存在
grep -oE '\]\((references|scripts|assets)/[^)]+\)' ./my-skill/SKILL.md
```

**对本项目的直接推论【论证】**：项目 01~04 系列单篇文档普遍 200-400 行，直接整体塞入 SKILL.md 会突破 500 行预算。正确做法是把 SKILL.md 写成"任务编排 + 验证清单"，将系统知识放到 `references/` 中按子主题拆分文件——这与本项目的"概念矩阵 / 速查 / 专章"分层天然同构（见 AI_SKILL-02）。

术语速查（本文档与后续篇共用口径）：

| 术语 | 含义 |
| ------ | ------ |
| Agent Skills | 技能开放标准及其格式统称（SKILL.md 为承载文件） |
| 渐进披露 | 元数据→指令→资源三层按需加载机制 |
| AAIF | Agentic AI Foundation（Linux 基金会旗下，托管 MCP/AGENTS.md/Agent Skills） |
| MCP | Model Context Protocol，Agent↔工具连接协议（与技能互补） |
| skills-ref | 官方参考实现校验器（github.com/agentskills/agentskills） |

## AIS.01.3 治理格局：AAIF 与三锚点项目

2025-12 起，Agent 生态的三个层面分别由三个中立项目覆盖，均托管于 Linux 基金会下的 Agentic AI Foundation（AAIF）：

| 层面 | 项目 | 出处 | 角色 |
| ------ | ------ | ------ | ------ |
| 协议（Agent↔工具连接） | MCP | Anthropic（2024-11 发布，2025-12 捐赠） | 标准客户端-服务器工具协议，经 SEP（Standards Evolution Proposal）流程演进 |
| 行为规范（Agent 行为约定） | AGENTS.md | OpenAI Codex 团队 2025 年起源，2025-12 捐赠 | 指导编码 Agent 的开放格式（本项目 AGENTS.md 同名但为项目私有规范，无冲突） |
| 能力封装（Agent 可装载技能） | Agent Skills | Anthropic（2025-10 发布，2025-12 开放规范，2026-10 捐赠） | SKILL.md 格式、发现机制与执行语义 |
| 实现框架 | goose | Block | Agent 框架（AAIF 锚点之一） |

治理要点【论证】：

1. **SEP 流程**：MCP 的技术决策经 SEP 提案流程，维护者保留技术自主权——变更可预期、可追踪。
2. **捐赠范围**：2026-10-22 的捐赠包含标准名称、Logo、GitHub 组织与域名（agentskills.io），治理中立性完整。
3. **与 AGENTS.md 的关系**：本项目根目录 AGENTS.md 是项目私有协作宪法（命名巧合），与 AAIF 的 AGENTS.md 开放格式同名不同物；两者可共存——项目规范约束"写什么内容"，技能约束"如何被 Agent 装载执行"。
4. **版本演进观察点**：`allowed-tools` 等实验字段的定稿、frontmatter 可能的新增字段、引用深度规则的松动/收紧——三项任一生效时，须回写 AI_SKILL-01 时间线并复核 AI_SKILL-03 规范。

## AIS.01.4 采用者生态（多平台支持现状）

截至 2026-11，公开资料可查的支持 Agent Skills / SKILL.md 的主要平台：

| 平台 | 支持方式 | 来源 |
| ------ | ---------- | ------ |
| Claude Code / Claude Agent SDK | 原生支持；`~/.claude/skills` 个人级、`.claude/skills` 项目级；`/` 显式调用 + 描述自动激活 | [platform.claude.com 文档](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) |
| OpenAI Codex CLI / ChatGPT | 采用开放标准（"build on the open agent skills standard"）；`~/.codex/skills` | [bosio.digital](https://bosio.digital/articles/skills-vs-agents)、[Daniel Vaughan](https://codex.danielvaughan.com/2026/05/05/agent-skills-open-standard-portable-skills-codex-cli-cross-agent/) |
| GitHub Copilot / VS Code | 直接读取项目文件夹中的 SKILL.md（与 Claude Code 共用目录） | [Nocent Docent](https://nocentdocent.wordpress.com/2026/01/05/anthropics-agent-skills/) |
| Cursor | 支持 Agent Skills 格式 | [Daniel Vaughan](https://codex.danielvaughan.com/2026/05/05/agent-skills-open-standard-portable-skills-codex-cli-cross-agent/) |
| Gemini CLI | 支持（含同意门控激活与分层发现） | [tomrochette.com 汇总](https://tomrochette.com/agents/skills/agent-skills-open-standard/) |
| Microsoft Copilot Studio / Agent Framework | 支持开放规范，实现渐进披露模式 | [Microsoft Learn](https://learn.microsoft.com/en-us/agent-framework/agents/skills) |
| LangChain DeepAgents | OSS Python 支持，启动时仅加载 name+description | [LangChain 文档](https://docs.langchain.com/oss/python/deepagents/skills) |
| 中国市场 CLI（含 Kimi Code 等） | 多家 CLI 已支持技能目录装载（本项目运行环境即通过技能目录提供 SKILL.md 技能） | 各产品文档【论证】 |

**平台差异提示【论证】**：`allowed-tools` 字段处于实验状态，各实现支持程度不同；为最大可移植性，关键约束应写在正文中而非仅依赖该字段。技能分发市场（skills.sh 等）质量参差，第三方技能应视同供应链依赖审查（见 AIS.01.5）。Anthropic 2026-10-22 公告将标准捐赠给 AAIF 时声称生态已有约 100 万 skills 发布、近 2.8 亿次安装【论证：转述官方公告，具体数字以 Anthropic/AAIF 披露为准】。

各平台装载路径速查（项目级，随平台版本演进请复查官方文档）：

```bash
# Claude Code / Codex / Copilot-VS Code / Kimi Code 项目级装载
mkdir -p .claude/skills && cp -r AI_Skills/skills/mq-selection .claude/skills/
mkdir -p .codex/skills  && cp -r AI_Skills/skills/mq-selection .codex/skills/
mkdir -p .agents/skills && cp -r AI_Skills/skills/mq-selection .agents/skills/   # Kimi Code 等
```

装载后的验证方法：重启会话 → 显式调用 `/mq-selection`（应执行）→ 输入不相关问题（不应误激活，AI_SKILL-05 AIS.05.4 的误激活率即此测量）。

## AIS.01.5 MQ 领域技能生态与安全研究

### MQ 主题相关公开技能/工具

| 名称 | 类型 | 内容 | 来源 |
| ------ | ------ | ------ | ------ |
| Lenses Kafka Skills | 技能集 | 面向 AI 工程 Agent 的 Kafka 技能，与 Kafka MCP server 配合实现"问对问题 + 写生产级应用" | [lenses.io 博客（2026-05-11）](https://lenses.io/blog/introducing-kafka-skills-for-ai-engineering-agents) |
| RabbitMQ Skill（Grade A） | 技能 | AMQP 协议、exchange/queue/binding 全覆盖，经安全测试 | [skillsdirectory.com](https://www.skillsdirectory.com/skills/claude-dev-suite-rabbitmq) |
| Messaging & Event-Driven Skill | 技能 | RabbitMQ/Kafka 与事件驱动架构后端开发 | [mcpmarket.com](https://mcpmarket.com/tools/skills/messaging-event-driven-architecture) |
| anthropics/skills | 参考实现库 | 官方 100+ 技能仓库，SKILL.md 结构的规范范例 | [Carina Lab 汇总](https://carinalab.ai/post/hottest-github-repositories-for-ai-agent-skills) |
| Kafka MCP 等 MQ MCP 服务器 | 工具协议层 | 与技能互补：MCP 提供"连接与执行"，技能提供"知识与流程" | [DataLLM Lab](https://www.datallmlab.com/blog/mcp-vs-skills.html) |
| RabbitMQ vs Kafka vs NATS for AI Agents | 对比分析 | 任务交接、request-reply、路由、回放、背压维度对比 MQ 作为 Agent 消息层 | [acemq.com（2026-10-27）](https://acemq.com/compare/message-brokers-for-ai-agents/) |

### 技能供应链安全研究（必读）

2026 年两篇学术研究对公开技能库做了安全分析，结论对"引入/制作技能"有直接约束：

- 论文《Towards Secure Agent Skills: Architecture, Threat Taxonomy, and Security Analysis》提出技能威胁分类学并给出安全分析框架（[arXiv:2604.02837](https://arxiv.org/html/2604.02837)）。
- 2026 年初两项研究发现：公开可用 Agent 技能中超过四分之一至少含一个安全漏洞，确认存在恶意技能的平均攻击面达四种（[Deuce.Works 综述](https://ishchuk.eu/blog/why-installing-third-party-ai-agent-skills-is-riskier-than-you-think-in-2026)）【论证：转述 secondary source，定量结论以原文为准】。

**本项目红线（写入 AI_SKILL-03 规范）**：项目自制技能一律附带 `license` 字段与 `metadata.source-doc` 溯源；引用第三方技能前执行与引入依赖同等级的审查（审 SKILL.md 正文中的命令执行、脚本外联、凭证读取）。审查四级清单：

```text
L1 来源可信度：仓库组织可信度、star/维护频率、是否有签名或锁定版本
L2 正文命令审计：SKILL.md 中所有 Bash/脚本命令是否声明意图、是否有未声明外联
L3 脚本行为审计：scripts/ 内可执行文件的读写路径、网络目标、环境变量依赖
L4 版本锁定：引入时记录 commit/tag，升级走评审（与项目依赖同流程）
```

### Skills 与 MCP 的分工（为什么 MQ 场景两者都需要）

| 维度 | MCP | Agent Skills |
| ------ | ----- | -------------- |
| 本质 | 连接协议：让 Agent 调用外部工具/API | 知识封装：让 Agent 知道怎么做某类任务 |
| MQ 场景示例 | 连接 Kafka 集群执行 `kafka-topics.sh`、查 RabbitMQ Management API | 知道"Kafka 4.0 升级要先跑 upgrade-check、ZooKeeper 已移除"这类流程知识 |
| 类比 | 手（执行） | 脑（流程） |

## AIS.01.6 对本项目的对齐含义

1. **载体选型【论证】**：以 SKILL.md 为项目技能化唯一载体，符合开放标准与 AAIF 治理方向，可一次制作在 Claude Code/Codex/Cursor/Copilot 等多端装载。
2. **结构选型【论证】**：项目知识"厚"、技能预算"薄"，必须采用"SKILL.md 编排 + references 分主题"结构，禁止把 01~04 系列整篇复制进技能。
3. **治理继承**：技能内容沿用项目 AGENTS.md 第 4 节三级置信标注（【定理】/【论证】/【估算】）与第 6 节内容红线，确保"技能化"不降低事实可溯源标准。
4. **差异化定位**：国际 MQ 技能生态以 Kafka/RabbitMQ 英文技能为主，MQTT/NATS/Pulsar/Redis Stream 及中文语料覆盖薄弱（AIS.01.5 表），本项目 6 大系统 + RocketMQ/Redpanda 的全覆盖知识库恰好填补该空白。
5. **测试衔接**：技能正确性依赖项目 Testing/ 体系的用例验证与纠正机制（见 TEST-05/TEST-06），形成"文档 → 技能 → 验证 → 修正"闭环。

落地自查表（每季度对照）：

- [ ] 引用本项目的技能描述与 agentskills.io 当前规范一致（字段/长度/命名）
- [ ] 已登记技能的 `last-verified` 距今 < 6 个月
- [ ] 新增系统专章（01 系列）后 30 天内完成对应技能 references 对账
- [ ] 第三方技能引用均通过四级审查并留档

> 规范引用优先级：agentskills.io 原文 > 本文转述；两者冲突时以原文为准并回写修订本文。

## AIS.01.7 参考来源

- [Agent Skills 开放规范（agentskills.io/specification）](https://agentskills.io/specification)
- [Agent Skills 官网（agentskills.io）](https://agentskills.io/)
- [Anthropic 捐赠 Agent Skills 给 AAIF（Techmeme，2026-10-22）](https://www.techmeme.com/261022/p53)
- [MCP 捐赠与 AAIF 治理（DataLLM Lab）](https://www.datallmlab.com/blog/mcp-vs-skills.html)
- [Claude Skills 六个月生态盘点（Axis Future）](https://www.jakecuth.com/work/claude-skills-lab/)
- [Agent Skills 威胁分类学（arXiv:2604.02837）](https://arxiv.org/html/2604.02837)
- [Microsoft Agent Framework Skills（Microsoft Learn）](https://learn.microsoft.com/en-us/agent-framework/agents/skills)
- [LangChain DeepAgents Skills 文档](https://docs.langchain.com/oss/python/deepagents/skills)
- [Lenses Kafka Skills 发布博客（2026-05-11）](https://lenses.io/blog/introducing-kafka-skills-for-ai-engineering-agents)
- [AGENTS.md 开放格式指南（llms-txt.io）](https://llms-txt.io/blog/what-is-agents-md)

---

**最后更新**: 2026-11-18
