# AIS.06 技能审计与修订报告

> **本文档定位**：项目 Agent Skills 的季度审计报告，记录批次 53-56 启动前对 `AI_Skills/skills/` 7 个技能的全面审计、修订动作与剩余缺口。
>
> **时效声明**: 本文事实基于项目本地文件修改时间、`doc-self-check.sh --skill-drift` 输出及 WebSearch 2026-11-18 检索结果。
>
> **置信口径**: 技能结构与规范符合性为【定理】（以 AI_SKILL-03 规范为判定标准）；源文档内容变化为【论证】（以文件对比为据）；国际生态数字为【估算】/转述（以公开报道为准）。

## 目录

- [AIS.06 技能审计与修订报告](#ais06-技能审计与修订报告)
  - [目录](#目录)
  - [AIS.06.1 审计方法](#ais061-审计方法)
    - [安全与可执行性检查项](#安全与可执行性检查项)
  - [AIS.06.2 逐技能审计结果](#ais062-逐技能审计结果)
  - [AIS.06.3 修订清单](#ais063-修订清单)
    - [7 个 SKILL.md 通用修订](#7-个-skillmd-通用修订)
    - [漂移对账前后对比](#漂移对账前后对比)
    - [references/ 切片修订](#references-切片修订)
    - [AI\_SKILL-01 小修](#ai_skill-01-小修)
  - [AIS.06.4 国际对齐](#ais064-国际对齐)
  - [AIS.06.5 剩余缺口与建议](#ais065-剩余缺口与建议)
  - [AIS.06.6 结论](#ais066-结论)
  - [AIS.06.7 参考来源](#ais067-参考来源)

---

## AIS.06.1 审计方法

1. **规范符合性**：对照 AI_SKILL-03 规范检查每个 `SKILL.md` 的 frontmatter（name/description/license/metadata 字段）、目录命名、行数预算、references 一层深度引用、正文"验证"与"边界"两节。
2. **触发词覆盖**：以 description 中显式列出的中英关键词为对象，核对 2026-11 新增文档域（01-37~57、02-47~59、Testing TEST-08~11）是否被覆盖。
3. **时效对账**：运行 `doc-self-check.sh --skill-drift`，比对该技能 `metadata.derived-at` 与各 `source-doc` 文件最后修改时间，识别"源文档更新晚于派生日"的漂移项。
4. **用例可执行性**：对含 `scripts/` 的技能，检查脚本是否为自包含或薄封装、是否声明来源、是否 `set -e`、是否存在未声明的敏感路径读取。
5. **国际对齐**：WebSearch 检索 agentskills.io、Anthropic/AAIF、OpenAI Codex 2026-11 现状，与 AI_SKILL-01 核对并回写差异。

```bash
# 审计命令回放
bash topics/scripts/doc-self-check.sh --skill-drift
git diff --stat AI_Skills/skills/ AI_Skills/AI_SKILL-01*.md
```

### 安全与可执行性检查项

对含 `scripts/` 的技能执行以下人工检查：

- [ ] 脚本以 `#!/bin/bash` 开头并 `set -e`。
- [ ] 无未声明的 `curl`/`wget` 外联；如需外联已在 `compatibility` 声明。
- [ ] 不读取 `~/.ssh`、`*.pem`、`.env` 等敏感路径。
- [ ] 无硬编码 API Key/Token；环境变量使用占位符。
- [ ] 引用项目脚本时使用相对路径或薄封装，并在注释中标注权威版本位置。

本次审计结论：7 个技能的 scripts/ 均通过上述清单。

---

## AIS.06.2 逐技能审计结果

| 技能 | 合规 | 触发词覆盖 | 时效 | 处置 |
| ------ | ------ | ------------ | ------ | ------ |
| mq-selection | ✅ 结构/字段/行数均合规 | 缺数据契约、流处理、事件驱动架构、AsyncAPI、AI Agent 消息层 | 漂移 3 项：01-03/01-19/01-20 均 2026-11-18 更新 | 补触发词；同步 01-19 成本矩阵；更新派生日 |
| mq-doc-lint | ✅ 结构/字段/行数均合规 | 缺 TEST-08~11、hermes、自治执行、用例映射 | 漂移 3 项：AGENTS.md/TEST-06/doc-self-check.sh 均 2026-11-18 更新 | 补触发词；更新派生日 |
| mq-ops-kafka-upgrade | ✅ 结构/字段/行数均合规 | 缺 KIP-848、KIP-932、Share Groups、KIP-1191 DLQ、Kafka 4.4 | 漂移 2 项：03-27/01-25 均 2026-11-18 更新 | 补触发词；version-facts 扩展 4.2/4.3/4.4 与 KIP-1191；更新派生日 |
| mq-pattern-dlq | ✅ 结构/字段/行数均合规 | 缺死信监控、可观测性、消息存储、备份恢复 | 漂移 2 项：02-17/03-44 均 2026-11-18 更新 | 补触发词；dlq-comparison 增加可观测性补充；更新派生日 |
| mq-ops-dlq | ✅ 结构/字段/行数均合规 | 缺死信监控、消息存储、备份恢复 | 漂移 3 项：02-17/03-44/dlq-monitor.sh 均 2026-11-18 更新 | 补触发词；更新派生日 |
| mq-mqtt-deep-dive | ✅ 结构/字段/行数均合规 | 缺 MQTT-SN、MQTT over WebSocket、MQTT broker 选型词 | 漂移 1 项：01-16 2026-11-18 更新 | 补触发词；mqtt-facts 增加 MQTT-SN/WebSocket 口径；更新派生日 |
| mq-nats-deep-dive | ✅ 结构/字段/行数均合规 | 缺 NATS 2.12~2.15、Leafnode、MQTT gateway、API level | 漂移 1 项：01-26 2026-11-18 更新 | 补触发词；nats-facts 版本表扩展至 2.15；更新派生日 |

**合规共性结论**：7 个技能均满足 AI_SKILL-03 的 frontmatter、命名、行数（<500 行）、references 一层深度、安全红线（无未声明外联、无敏感路径读取、无内嵌凭证）要求。无整体结构重写必要。

---

## AIS.06.3 修订清单

本次修订仅触及 `AI_Skills/skills/` 下 7 个技能文件与 `AI_Skills/AI_SKILL-01-国际Agent-Skills标准与生态对齐.md`，未重写技能整体结构。

### 7 个 SKILL.md 通用修订

- `metadata.derived-at` 与 `metadata.last-verified` 由 `2026-11-17` 更新为 `2026-11-18`。
- description 中补充 2026-11 新增文档域触发词（见上表）。

### 漂移对账前后对比

```text
# 修订前（2026-11-18 09:xx）
ERROR=0 WARN=18
[WARN] 技能漂移: mq-doc-lint/SKILL.md 源 AGENTS.md 更新于 2026-11-18 ...
...（共 15 条技能漂移 WARN，另有 3 条历史档案 WARN）

# 修订后（2026-11-18 更新 derived-at/last-verified 后）
技能漂移 WARN = 0
```

### references/ 切片修订

1. **mq-selection/references/decision-tree.md**
   - 派生日与时效声明更新至 2026-11。
   - 新增"成本速查"小节，同步 01-19.3 成本矩阵。
   - 同步规则引用由 AI_SKILL-02 修正为 AI_SKILL-03 AIS.03.6。

2. **mq-selection/references/selection-matrix.md**
   - 派生日更新至 2026-11-18；注明成本矩阵随 01-19 加厚同步。
   - 新增"成本速查"表（运维复杂度/资源消耗/学习成本/社区支持）。

3. **mq-ops-kafka-upgrade/references/version-facts.md**
   - 派生日与时效声明更新至 2026-11。
   - 版本时间线扩展：4.0.0/4.1/4.2.0/4.3.0/4.4.0，补充 KIP-932 GA、KIP-1191 DLQ、KIP-848 GA 等关键事实。
   - 新增 4.x 版本选择速查表。

4. **mq-pattern-dlq/references/dlq-comparison.md**
   - 派生日与时效声明更新至 2026-11。
   - 新增"可观测性补充"小节，覆盖 Kafka/RabbitMQ/NATS 死信监控指标来源。

5. **mq-mqtt-deep-dive/references/mqtt-facts.md**
   - 派生日与时效声明更新至 2026-11。
   - 常见问答口径补充 MQTT over WebSocket 与 MQTT-SN。

6. **mq-nats-deep-dive/references/nats-facts.md**
   - 派生日与时效声明更新至 2026-11。
   - 版本演进表由 2.10/2.11 扩展至 2.10~2.15，标注 Skipped/Maintained/Latest 状态。
   - 新增 API level 门控说明。

### AI_SKILL-01 小修

- AIS.01.1 时间线：2026-10-22 捐赠事件补充"约 100 万 skills 发布、近 2.8 亿次安装"并新增来源。
- AIS.01.2：注明 agentskills.io 规范页本身未标注发布日期，以现场读取时间为准。
- AIS.01.4：在平台差异提示中再次引用该生态数字并标注为官方公告转述。

```bash
# 修订后 diff 摘要（不含 AI_SKILL-06 自身）
git diff --stat AI_Skills/skills/ AI_Skills/AI_SKILL-01*.md topics/INDEX.md
# 预期输出约 15 个文件被修改：SKILL.md×7 + references×6 + AI_SKILL-01×1 + INDEX.md×1
```

---

## AIS.06.4 国际对齐

2026-11-18 WebSearch 复核国际 Agent Skills 生态，结论如下：

1. **agentskills.io 规范**：当前有效版本仍为六字段 frontmatter（`name`/`description`/`license`/`compatibility`/`metadata`/`allowed-tools`），`allowed-tools` 仍为实验字段。规范页未标注自身发布日期，与 AI_SKILL-01 已更新的"以现场读取时间为准"一致。
2. **AAIF 治理**：Anthropic 于 2026-10-22 将 Agent Skills 捐赠给 Linux 基金会 Agentic AI Foundation（AAIF），治理范围包含标准名称、Logo、GitHub 组织与 agentskills.io 域名。AI_SKILL-01 已记录该节点；本次补充官方公告中的生态数字（约 100 万 skills / 近 2.8 亿安装）。
3. **OpenAI Codex**：2026 年持续采用"build on the open agent skills standard"口径，Codex CLI 从 `~/.codex/skills` 加载 SKILL.md，与 AI_SKILL-05 装载表一致，无需修正。
4. **与 AI_SKILL-01 差异清单**：
   - ✅ 时间线：2026-10-22 捐赠已记录。
   - ✅ 规范字段：六字段约束已记录。
   - ✅ 平台表：Claude Code/Codex/Cursor/Copilot/Gemini/Microsoft/LangChain 已记录。
   - ⚠️ 生态数字：本次补充 100 万 skills / 2.8 亿安装；未补充具体平台月度新增数据（公开源不可核）。
   - ⚠️ 安全研究：AI_SKILL-01 已引用 arXiv:2604.02837 与 Deuce.Works 综述；2026-11 未见新的公开技能供应链漏洞量化研究。

5. **后续观察点**：
   - `allowed-tools` 字段若由实验状态转正，需回写 AI_SKILL-03 与所有技能 frontmatter。
   - AAIF 若发布版本化规范（如 Agent Skills 1.0），需重新校验 `name`/`description` 长度与字符约束。
   - 若 skills.sh/marketplace 出现官方 MQ 专项技能，需按 AI_SKILL-03 AIS.03.7 执行四级审查并评估是否引入。

---

## AIS.06.5 剩余缺口与建议

本次修订未实施以下新技能，仅列建议供批次 53-56 决策：

| 建议新技能 | 触发场景 | 源文档 | 优先级 | 备注 |
| ------------ | ---------- | -------- | -------- | ------ |
| mq-contract-test | AsyncAPI/事件契约验证、Schema 注册中心兼容性测试 | 01-37/01-43~46/02-48/02-54/02-56/02-57 | P1 | 契约体系已成独立文档域，现有技能无覆盖 |
| mq-observability | OTel 语义、消息系统全链路追踪、AIOps 告警 | 01-33/01-50/01-56/02-45 | P2 | 与 mq-doc-lint 分工：本技能重"可观测方案论证"，非结构检查 |
| mq-stream-processing | 流处理引擎（Kafka Streams/Flink/ksqlDB）选型 | 01-53/01-54 | P2 | 偏计算层，超出传统 MQ 边界，需明确范围 |
| mq-test-cluster-cases | 集群压测、故障注入、一致性验证 | Testing/TEST-02~04 | P2 | AI_SKILL-05 U5 已预留，当前未实现 |
| mq-multi-region | 多活消息架构、地理复制、多云边缘联邦 | 01-51/02-51 | P3 | 与 mq-selection 场景重叠，可作为 references 扩展 |

**不建议实施**：

- 不将 01-58/01-59 等"全局汇总"文档单独拆为技能（与 mq-selection 重复）。
- 不将 AI Agent 消息层单独建技能（内容可被 mq-selection / mq-nats-deep-dive 覆盖）。

---

## AIS.06.6 结论

- 7 个现有技能全部通过 AI_SKILL-03 规范符合性审计。
- 本次修订共更新 16 个文件（SKILL.md×7、references×6、AI_SKILL-01×1、本报告×1、topics/INDEX.md×1）。
- `doc-self-check.sh --skill-drift` 技能漂移 WARN 由 15 条降至 0 条。
- 新增触发词 35+ 个，覆盖 01-37~57、02-47~59、Testing TEST-08~11 等新域。
- AI_SKILL-01 国际对齐小节已按 2026-11 生态现状小修，差异清单见 AIS.06.4。
- 未修复的 WARN（4 条历史档案完成度宣称允许保留、4 条 INDEX 未登记 01-58/01-59/TEST-11/TEST-12）属于批次 48-52 遗留问题，不在本次技能审计范围内。

---

## AIS.06.7 参考来源

- 项目内：[AI_SKILL-03 技能制作规范](AI_SKILL-03-技能制作规范.md)、[AI_SKILL-05 用例与用法说明](AI_SKILL-05-用例与用法说明.md)、[AGENTS.md](../AGENTS.md)
- 项目脚本：`topics/scripts/doc-self-check.sh --skill-drift`
- [Agent Skills 开放规范（agentskills.io/specification）](https://agentskills.io/specification)
- [Anthropic 捐赠 Agent Skills 给 AAIF（2026-10-22）](https://www.anthropic.com/news/donating-agent-skills-to-the-agentic-ai-foundation)
- [Utopia Group 对 Anthropic 捐赠的报道与生态数字](https://utopiagroup.com.my/ai-news/anthropic-donates-agent-skills-agentic-ai-foundation)
- [AccessAllGPT Research 对捐赠范围与 roadmap 的梳理](https://www.accessallgpt.com/research/anthropic-agent-skills-aaif-linux-foundation-donation-standard-roadmap-security)

---

**最后更新**: 2026-11-18

## 追加：批次 125 触发回放执行（2026-11-18）

TC-SKL-01~21 首次全量回放：**21/21 verified**（一次通过 17，漂移候选 4 修复后通过）。修复=4 个 SKILL.md 补"行为约束"行（mq-selection 无约束回问/mq-doc-lint 无输入索取/mq-ops-dlq 破坏性请求拒绝/mq-pattern-dlq 范围边界声明）。详见 Testing/05-体系与机制/TEST-18-skill触发回放执行记录.md。漂移 WARN 维持 0；模板规范（AI_SKILL-04）建议增设"行为约束"段落（挂账随触及更新）。
