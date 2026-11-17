# AIS.03 技能制作规范

> **本文档定位**：项目内 Agent Skills（SKILL.md）的制作、评审与维护规范。是 [AGENTS.md](../AGENTS.md) 第 3、4、6 节在技能形态的扩展适用；与开放标准冲突时以 [agentskills.io 规范](https://agentskills.io/specification) 为准并回写修订。

## 目录

- [AIS.03 技能制作规范](#ais03-技能制作规范)
  - [目录](#目录)
  - [AIS.03.1 规范层级与适用范围](#ais031-规范层级与适用范围)
  - [AIS.03.2 命名与目录规范](#ais032-命名与目录规范)
  - [AIS.03.3 Frontmatter 规范](#ais033-frontmatter-规范)
  - [AIS.03.4 正文结构规范](#ais034-正文结构规范)
  - [AIS.03.5 渐进披露预算与拆分规则](#ais035-渐进披露预算与拆分规则)
  - [AIS.03.6 引用、置信与时效规则](#ais036-引用置信与时效规则)
  - [AIS.03.7 安全红线](#ais037-安全红线)
  - [AIS.03.8 评审清单与验收](#ais038-评审清单与验收)
  - [AIS.03.9 参考来源](#ais039-参考来源)

---

## AIS.03.1 规范层级与适用范围

| 层级 | 文件 | 约束力 |
| ------ | ------ | -------- |
| L0 开放标准 | agentskills.io specification | 全球一致性强约束（frontmatter 字段、命名、目录结构） |
| L1 项目宪法 | AGENTS.md §3/§4/§6 | 内容质量约束（密度、置信三级标注、事实可溯源、不造数据） |
| L2 本规范 | 本文档 | 技能形态专项约束（命名域、frontmatter 扩展、评审流程） |
| L3 技能自身 | 每个 SKILL.md | 单技能的范围与边界声明 |

适用范围：项目自制技能（`AI_Skills/skills/` 目录）、个人/项目级装载的技能副本、引用第三方技能的本项目改写版。直接引用未改写的第三方技能不适用 L2/L3，但适用 AIS.03.7 安全红线的审查要求。

## AIS.03.2 命名与目录规范

**命名格式**：`mq-<域>-<任务>`，全小写 kebab-case（开放标准强制），总长度 ≤64 字符，不得连续连字符，首尾不得为连字符。

| 域段取值 | 含义 | 示例 |
| ---------- | ------ | ------ |
| `mq-<system>-deep-dive` | D1 系统专章技能 | `mq-kafka-deep-dive` |
| `mq-selection` / `mq-scenario-*` | D2 场景选型技能 | `mq-scenario-iot` |
| `mq-pattern-<模式>` | D3 设计论证类技能 | `mq-pattern-dlq` |
| `mq-ops-<任务>` | D3/D4 操作清单类技能 | `mq-ops-dlq`、`mq-ops-kafka-upgrade` |
| `mq-test-<范围>` | D5 测试验证技能 | `mq-test-cluster-cases` |
| `mq-doc-<治理项>` | D6 知识治理技能 | `mq-doc-lint` |

**目录布局**（开放标准要求 name 与父目录名一致）：

```text
AI_Skills/skills/
├── mq-selection/
│   ├── SKILL.md
│   └── references/
│       ├── decision-tree.md
│       └── selection-matrix.md
├── mq-ops-kafka-upgrade/
│   ├── SKILL.md
│   ├── references/
│   │   └── version-facts.md        # 带时效声明的版本事实切片
│   └── scripts/
│       └── preflight-check.sh      # 可来自 topics/scripts/ 的引用副本
└── ...
```

**禁止项**：目录名大写/下划线（`MQ-Selection`、`mq_selection` 均非法）；一个技能目录塞多个系统的知识（违反单职责）；把 `topics/` 文档以软链接方式挂进技能（便携性破坏，必须派生切片）。

## AIS.03.3 Frontmatter 规范

开放标准必填 `name`、`description`；项目扩展以下字段（放入 `metadata` 或顶层，不得与标准字段冲突）：

| 字段 | 层级 | 必填 | 约束 |
| ------ | ------ | ------ | ------ |
| `name` | 标准 | 是 | 同目录名；`mq-` 前缀；规则见 AIS.03.2 |
| `description` | 标准 | 是 | ≤1024 字符；必须含"功能 + 何时用 + 触发关键词（中英）"；写法见下 |
| `license` | 标准 | 否（项目必填） | 项目技能统一 `Apache-2.0`（与项目 LICENSE 一致） |
| `compatibility` | 标准 | 否 | 需要外部依赖时必填（如 `Requires docker, jq, bash`） |
| `metadata.source-doc` | 项目 | 是 | 源文档相对路径列表（可多行） |
| `metadata.derived-at` | 项目 | 是 | 派生日期 `YYYY-MM-DD` |
| `metadata.mq-system` | 项目 | 是 | 关联系统：`kafka/nats/rabbitmq/pulsar/redis/mqtt/rocketmq/redpanda/multi` |
| `metadata.project` | 项目 | 是 | 固定 `Mq-knowledge-base` |
| `metadata.status` | 项目 | 否 | `active/stale/deprecated`（默认 active） |
| `metadata.last-verified` | 项目 | 是 | 内容核实日期 `YYYY-MM-DD` |
| `allowed-tools` | 标准（实验） | 否 | 仅当需要预批准工具时声明；关键限制仍须写进正文 |

**description 写法模板**（触发率是技能质量第一指标）：

```yaml
# ✅ 项目推荐写法：一句话功能 + 触发场景 + 关键词（中英）
description: >
  论证并推荐消息队列技术选型方案（日志聚合/IoT/微服务/金融场景），
  基于项目 01-03/01-19/01-20 决策树与选型矩阵输出带置信标注的建议。
  Use when 用户问"选 Kafka 还是 Pulsar/NATS/RabbitMQ"、技术选型、
  technology selection、message broker comparison、MQ 对比论证。

# ❌ 反例
description: 帮助进行消息队列选型。
```

完整 frontmatter 示例（含全部项目扩展字段，制作时照此填写）：

```yaml
---
name: mq-pattern-dlq
description: >
  死信队列（DLQ）设计论证：六系统 DLX/TTL/重试上限机制对比与方案推荐……（≤1024 字符）
license: Apache-2.0
metadata:
  source-doc: topics/02-场景驱动架构设计/02-17-死信队列设计.md
  derived-at: "2026-11-17"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
  status: active
---
```

## AIS.03.4 正文结构规范

SKILL.md 正文是"任务编排书"，按以下骨架编写（括号内为写作要点）：

```markdown
---
name: mq-ops-kafka-upgrade
description: ...（见 AIS.03.3）
license: Apache-2.0
metadata:
  source-doc: topics/03-架构与运维实践/03-27-版本升级指南.md
  derived-at: "2026-11-17"
  mq-system: kafka
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
---

# Kafka 版本升级操作

## 适用范围
（什么场景触发本技能：源/目标版本组合、集群规模前提）

## 前置检查
（执行前必须确认的 3-5 项，含具体命令）

## 操作步骤
（编号步骤；每步一条命令或一个决策点；危险步骤标注⚠️）

## 验证
（每步的"完成定义"：命令 + 预期输出）

## 边界与红线
（本技能不处理什么；回滚入口指向哪个技能/文档）

## 参考
（相对路径一层深度的 references/scripts 引用）
```

写作规则：

1. 祈使句、命令先行，解释后置（Agent 优先执行后理解）。
2. 每个定量声明保留源文档的置信标注与来源链接（AGENTS.md §4.1）。
3. 版本事实（版本号/发布日期/KIP 状态）必须带时效声明行，且 `last-verified` 不早于源文档核实日期。
4. 与 02/03 分工对齐：论证类技能正文给"决策依据 + 对比表指针"；操作类技能正文给"步骤 + 验证命令 + 检查清单"。

论证类技能（D1/D2/D3 设计侧）的正文骨架示例：

```markdown
# 死信队列设计论证

## 决策输入
（向用户收集的 3 类约束：消息价值等级 / 重试策略 / 运维成本上限；不足则反问）

## 论证路径
1. 查 references/dlq-comparison.md 取六系统机制对比
2. 按决策矩阵收敛方案组合（输出格式：推荐 + 备选 + 关键权衡）
3. 互链操作类技能 mq-ops-dlq 落地

## 输出格式
- 结论（一句话 + 置信标注）
- 对比表（≤7 行，更多细节在 references）
- 不适用边界（本方案何时失效）

## 红线
- 禁止无约束直接给单一系统结论
- 版本能力引用必须带时效
```

## AIS.03.5 渐进披露预算与拆分规则

| 项目 | 预算 | 超限处置 |
| ------ | ------ | ---------- |
| SKILL.md 总行数 | < 500 行 | 按子主题拆 references/ |
| SKILL.md 正文 token | < 5000 | 优先移表格/长代码块到 references |
| 单个 reference 文件 | 建议 < 300 行 | 再按子主题二级拆分（保持一层深度引用链） |
| scripts 单文件 | 无硬限，须自包含 | 依赖外部命令时在 compatibility 声明 |
| 目录总大小 | 建议 < 1 MB | 大资源（基准数据集）放 assets/ 并压缩 |

拆分判断【论证】：当正文中出现"完整参数表/完整配置样例/多语言代码"任一元素即应下沉到 references；SKILL.md 只保留"做决策所需的阈值与开关"。

```bash
# 自检行数（纳入 doc-self-check.sh --skill 模式）
find skills -name SKILL.md | while read -r f; do
  lines=$(wc -l < "$f")
  [ "$lines" -ge 500 ] && echo "[FAIL] $f 超预算: ${lines} 行（规范 <500）"
done
```

## AIS.03.6 引用、置信与时效规则

1. **置信标注**：正文与 references 中所有 【定理】/【论证】/【估算】 标注随切片迁移，禁止在派生时降级或升级（AGENTS.md §4.1）。
2. **来源链接**：定量声明的链接相对项目根书写（如 `../../topics/01-25-...md`）或绝对 URL；失效链接由 doc-self-check.sh 检出（TEST-06）。
3. **时效声明**：凡引用"版本事实"的 reference 文件头部必须有 `> **时效声明**: 核实至 YYYY-MM。`；技能 frontmatter 的 `last-verified` 与其一致。
4. **更新流程**：源文档变更 → 运行 `--skill-drift` 对账 → 重新派生切片 → 更新 `derived-at`/`last-verified` → CHANGELOG 记条目。

## AIS.03.7 安全红线

针对公开技能供应链风险（AI_SKILL-01 AIS.01.5 引述的 2026 年安全研究），项目技能强制执行：

- [ ] SKILL.md 正文与 scripts 中**不得**出现未声明的网络外联（curl/wget 到项目外域名须在 compatibility 声明）
- [ ] scripts 不得读取 `~/.ssh`、`*.pem`、`.env` 等敏感路径（doc-self-check.sh 静态扫描）
- [ ] 不得内嵌 API Key/Token（一律走环境变量占位符）
- [ ] 第三方技能引入前完成四级审查：来源可信度 / 正文命令审计 / 脚本行为审计 / 版本锁定
- [ ] `allowed-tools` 为实验字段，权限收窄不能只依赖它——正文必须写明"未经确认不执行写操作"

## AIS.03.8 评审清单与验收

技能合并前逐项过检（不通过即退回）：

- [ ] frontmatter 通过 `skills-ref validate`（或人工按规范字段表核对）
- [ ] `name` 与目录名一致，`mq-` 前缀，≤64 字符
- [ ] `description` ≤1024 字符且含中英触发关键词
- [ ] `license`/`metadata.source-doc`/`derived-at`/`mq-system`/`last-verified` 齐全
- [ ] SKILL.md < 500 行；表格/长代码已下沉 references
- [ ] 版本事实带时效声明；定量声明带置信标注或来源
- [ ] 正文含"验证"与"边界与红线"两节
- [ ] AIS.03.7 安全清单全过
- [ ] 对应用例（AI_SKILL-05）回放通过
- [ ] doc-self-check.sh 无新增 FAIL

验收记录模板（附在技能目录 README 的登记表中）：

| 验收项 | 结果 | 证据位置 |
| -------- | ------ | ---------- |
| skills-ref validate | ✅ | 批次说明粘贴输出 |
| 用例回放 | ✅/退回 N 次 | AI_SKILL-05 回放记录 |
| 安全清单 | ✅ | AIS.03.7 逐项 |
| 登记入册 | ✅ | 技能目录 README 表新增行 |

退回规则：同一技能连续 2 次验收不通过 → 暂停制作，回到 AIS.02.2 重新判定映射（可能粒度拆分错误），并在批次报告记录根因。

## AIS.03.9 参考来源

- [Agent Skills 开放规范（字段约束原文）](https://agentskills.io/specification)
- [技能供应链安全风险综述（Deuce.Works）](https://ishchuk.eu/blog/why-installing-third-party-ai-agent-skills-is-riskier-than-you-think-in-2026)
- [Towards Secure Agent Skills（arXiv:2604.02837）](https://arxiv.org/html/2604.02837)
- 项目内：[AGENTS.md](../AGENTS.md) §3 密度标准、§4 三级置信标注、§6 内容红线

---

**最后更新**: 2026-11-18
