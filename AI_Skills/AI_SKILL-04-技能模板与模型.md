# AIS.04 技能模板与模型

> **本文档定位**：项目 Agent Skills 的可复制模板（三套）与模型样例（三个），配套 AI_SKILL-03 规范使用。复制模板时删除本定位行与本行下方所有"（填写提示）"注释。

## 目录

- [AIS.04 技能模板与模型](#ais04-技能模板与模型)
  - [目录](#目录)
  - [AIS.04.1 模板 A：系统专章技能（D1）](#ais041-模板-a系统专章技能d1)
  - [AIS.04.2 模板 B：场景选型技能（D2）](#ais042-模板-b场景选型技能d2)
  - [AIS.04.3 模板 C：操作清单技能（D3/D4）](#ais043-模板-c操作清单技能d3d4)
  - [AIS.04.4 模型样例 1：mq-ops-kafka-upgrade（技能成品）](#ais044-模型样例-1mq-ops-kafka-upgrade技能成品)
  - [AIS.04.5 模型样例 2：mq-pattern-dlq（技能成品）](#ais045-模型样例-2mq-pattern-dlq技能成品)
  - [AIS.04.6 模型样例 3：mq-doc-lint（治理技能）](#ais046-模型样例-3mq-doc-lint治理技能)
  - [AIS.04.7 附属文件模板（references / scripts）](#ais047-附属文件模板references--scripts)
  - [AIS.04.8 参考来源](#ais048-参考来源)

---

## AIS.04.1 模板 A：系统专章技能（D1）

适用：把 01-12~01-29 某系统专章包装为"随问随答的系统级顾问"。

```markdown
---
name: mq-<system>-deep-dive            # 例：mq-nats-deep-dive
description: >
  <系统名> 深度知识顾问：架构、核心机制、版本演进、与同类系统对比、
  选型与运维要点，基于项目 <源专章> 输出带置信标注的回答。
  Use when 用户询问 <System> 架构/机制/版本/对比/选型，
  <system> architecture, deep dive, comparison, 深度分析。
license: Apache-2.0
compatibility: 无外部依赖（纯知识型技能）
metadata:
  source-doc: topics/01-基础概念与对比分析/01-XX-<专章>.md
  derived-at: "YYYY-MM-DD"
  mq-system: <system>
  project: Mq-knowledge-base
  last-verified: "YYYY-MM-DD"
---

# <系统名> 深度知识顾问

## 我能回答什么
- 架构与核心机制（分层、存储、复制、一致性协议）
- 版本演进与关键变更（带时效：核实至 YYYY-MM）
- 与同类系统的差异对比
- 典型场景适配性与不适用边界

## 回答规则
1. 先查 references/<system>-facts.md 取事实，再组织回答。
2. 定量结论保留【论证】/【估算】标注与来源链接。
3. 版本事实以 references/version-timeline.md 的时效声明为准，超出时效范围时明示用户核实。

## 参考
- references/<system>-facts.md（机制事实切片）
- references/version-timeline.md（版本时间线切片）
```

## AIS.04.2 模板 B：场景选型技能（D2）

适用：01-03/01-19/01-20 决策树与选型矩阵的技能化，是项目最高频技能。

```markdown
---
name: mq-selection
description: >
  论证并推荐消息队列技术选型方案：按场景（日志聚合/IoT/微服务/金融/
  混合）、约束（延迟/吞吐/顺序/事务/运维成本）输出带置信标注的选型
  建议与备选方案。Use when 技术选型、选 Kafka 还是 Pulsar/NATS/
  RabbitMQ/Redis、message broker selection、MQ 对比论证、替换成替代方案评估。
license: Apache-2.0
metadata:
  source-doc: |
    topics/01-基础概念与对比分析/01-03-决策图网分析.md
    topics/01-基础概念与对比分析/01-19-选型决策矩阵.md
    topics/01-基础概念与对比分析/01-20-技术选型速查表.md
  derived-at: "YYYY-MM-DD"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "YYYY-MM-DD"
---

# 消息队列选型论证

## 决策流程
1. 提取用户场景的硬约束（延迟上限/吞吐/顺序/事务/连接数/运维成本）。
2. 按 references/decision-tree.md 逐层收敛候选系统（≤2 个）。
3. 用 references/selection-matrix.md 核对候选系统的约束满足度。
4. 输出：推荐方案 + 备选方案 + 关键权衡 + 置信标注 + 验证建议（指向 mq-test-* 技能）。

## 红线
- 不得脱离用户约束直接给单系统结论；约束不足时先反问。
- 涉及版本能力（如 Kafka 4.0 KIP-932 队列语义）必须引用 version-timeline 时效。

## 参考
- references/decision-tree.md（决策树切片，一层深度）
- references/selection-matrix.md（选型矩阵切片）
```

## AIS.04.3 模板 C：操作清单技能（D3/D4）

适用：03 系列专项指南与 03-39~62 消息运维实践的技能化。

```markdown
---
name: mq-ops-<任务>                      # 例：mq-ops-kafka-upgrade
description: >
  执行 <任务> 的标准操作流程与检查清单：<前置检查/步骤/每步验证/回滚入口>。
  Use when <中文任务词>、<system> <task>、<任务相关故障关键词>。
license: Apache-2.0
compatibility: Requires bash, <docker/jq/kubectl 等真实依赖>
metadata:
  source-doc: topics/03-架构与运维实践/03-XX-<指南>.md
  derived-at: "YYYY-MM-DD"
  mq-system: <system>
  project: Mq-knowledge-base
  last-verified: "YYYY-MM-DD"
---

# <任务名> 操作

## 适用范围
（源/目标版本、规模、环境前提）

## 前置检查
- [ ] 检查项 + 具体命令 + 通过标准

## 操作步骤
1. 步骤（命令）— 验证：预期输出
2. ⚠️ 危险步骤（说明风险与暂停确认点）

## 回滚
（触发条件 + 回滚命令 + 入口文档）

## 边界与红线
（本技能不处理什么；何时升级找人工/源文档）

## 参考
- references/runbook.md
- scripts/<helper>.sh
```

## AIS.04.4 模型样例 1：mq-ops-kafka-upgrade（技能成品）

以下为可直接使用的成品示例（压缩展示；正式版按模板 C 展开）：

```markdown
---
name: mq-ops-kafka-upgrade
description: >
  Kafka 集群版本升级操作流程：升级前预检、滚动升级步骤、每步验证命令、
  回滚入口与检查清单，覆盖 3.x→4.x（ZooKeeper 移除）与 4.x 小版本场景。
  Use when Kafka 升级、版本升级、rolling upgrade、KRaft 迁移、
  kafka 版本回滚、升级失败处理。
license: Apache-2.0
compatibility: Requires bash, kafka-topics.sh, kafka-broker-api-versions.sh
metadata:
  source-doc: |
    topics/03-架构与运维实践/03-27-版本升级指南.md
    topics/01-基础概念与对比分析/01-25-Kafka-4.0新时代与队列语义分析.md
  derived-at: "2026-11-17"
  mq-system: kafka
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
---

# Kafka 版本升级操作

## 适用范围
- 目标版本 Kafka 4.x（KRaft 模式；ZooKeeper 模式须先完成 KRaft 迁移）
- 集群规模 ≤ 50 broker（更大规模见源文档 03-27 的批次策略）

## 前置检查
- [ ] `kafka-broker-api-versions.sh --bootstrap-server <b> | grep 4.` 确认当前版本
- [ ] `kafka-topics.sh --describe` 确认无 under-replicated partitions（非空则先修复）
- [ ] 备份 `server.properties` 与 JMX 指标基线（scripts/preflight-check.sh）

## 操作步骤
1. 升级 Controller（KRaft）：替换二进制 → 滚动重启 → 验证：
   `kafka-metadata-quorum.sh describe --bootstrap-server <b>` 输出稳定 leader。
2. ⚠️ 逐 broker 升级：先停流（cruise control 或手动副本重分配止血）再替换二进制。
3. 每步验证：`kafka-topics.sh --describe` URP=0；`kafka-consumer-groups.sh --describe` 无 STUCK。

## 回滚
4.x→3.x 不支持直接回滚（log format 前进）；回滚窗口内仅支持同 major 版本降级。详见 references/version-facts.md。

## 边界与红线
- 不处理跨 major 的 ZooKeeper→KRaft 迁移（单独技能 mq-ops-kafka-migration）。
- 4.0 移除 ZooKeeper 为版本事实【论证：Kafka 官方发布说明】，执行前以官方文档复核。
```

## AIS.04.5 模型样例 2：mq-pattern-dlq（技能成品）

```markdown
---
name: mq-pattern-dlq
description: >
  死信队列（DLQ）设计论证：六系统 DLX/TTL/重试上限/重投策略机制对比，
  按业务损失等级给出 DLQ 方案选型建议。Use when 死信队列、DLQ、
  dead letter、重试上限、消息堆积处理、retry exhaustion、poison message。
license: Apache-2.0
metadata:
  source-doc: |
    topics/02-场景驱动架构设计/02-17-死信队列设计.md
    topics/03-架构与运维实践/03-44-消息存储与备份恢复指南.md
  derived-at: "2026-11-17"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
---

# 死信队列设计论证

## 决策输入
消息价值等级（丢弃可接受/可延迟/不可丢）、重试策略、运维成本上限。

## 论证步骤
1. 查 references/dlq-comparison.md 取得六系统机制对比（Kafka 无内建 DLX，
   靠重试 topic + 人工/连接器转移；RabbitMQ 内建 DLX；NATS JetStream
   用 maxDeliver；Pulsar 用 retry/dead letter topic）。
2. 按"消息价值等级 × 系统现状"输出方案组合（如：Kafka + 重试 topics 三层 +
   S3 归档兜底）。
3. 操作落地引导至 mq-ops-dlq 技能（互链见 AI_SKILL-02）。

## 边界
不提供代码级实现（见 examples/ 各语言示例）；不给"重试次数越多越好"式
无依据建议（默认上限与依据见 references/dlq-comparison.md，标【估算】处须明示）。
```

## AIS.04.6 模型样例 3：mq-doc-lint（治理技能）

```markdown
---
name: mq-doc-lint
description: >
  项目知识库规范性自检：密度标准、三级置信标注、定位声明、索引登记、
  死链与归档引用检测，输出可执行的修正清单。
  Use when 文档治理、规范检查、doc lint、索引同步检查、知识库自检、
  AGENTS.md 验收。
license: Apache-2.0
compatibility: Requires bash, grep, find, awk
metadata:
  source-doc: |
    AGENTS.md
    Testing/05-体系与机制/TEST-06-自我验证机制与脚本说明.md
  derived-at: "2026-11-17"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
---

# 知识库规范性自检

## 执行
运行 scripts/doc-self-check.sh（或项目 topics/scripts/doc-self-check.sh）。
模式：quick（结构）/ full（+密度抽样）/ --skill-drift（技能漂移对账）。

## 解读输出
- FAIL：必须修复（死链、归档引用、frontmatter 非法、超预算）
- WARN：批次内修复（密度偏薄、索引未登记、时效过期）

## 修复原则
只修检测到的问题，不顺手重构；修复后复跑直到全绿；结果记入 CHANGELOG。
```

## AIS.04.7 附属文件模板（references / scripts）

**references/REFERENCE.md 骨架**：

```markdown
# <切片名>（派生自 <源文档相对路径>，派生日 YYYY-MM-DD）

> **时效声明**: 本文事实核实至 YYYY-MM。（涉版本事实时必填）

## <子主题 1>
（切片内容：保留源文档的标注/链接/表格，删除与任务无关章节）

## <子主题 2>
...

---
**同步规则**: 源文档更新后须重新派生并更新 derived-at / last-verified。
```

**scripts/ 脚本骨架**（与 topics/scripts/ 风格一致：bash、`set -e`、参数化、中文输出）：

```bash
#!/bin/bash
# <脚本功能一句话>
set -e
PARAM=${1:-"default"}

echo "=== <标题> ==="
if ! command -v <依赖命令> &> /dev/null; then
    echo "❌ 未找到 <依赖命令>，请先安装"
    exit 1
fi
# 主逻辑（含错误处理与预期输出断言）
echo "✅ 完成"
```

**预算核对表**（交付前最后一遍）：

| 核对项 | 标准 | 工具 |
| -------- | ------ | ------ |
| SKILL.md 行数 | < 500 | `wc -l` |
| frontmatter 合法性 | 规范字段全过 | `skills-ref validate` 或 doc-self-check.sh --skill |
| 引用链深度 | 一层 | 人工检查 references 内不再链 references |
| description 长度 | ≤1024 | 人工 |
| 敏感信息 | 无密钥/无私钥路径 | doc-self-check.sh 安全扫描 |

## AIS.04.8 参考来源

- [Agent Skills 开放规范（目录结构/字段/预算原文）](https://agentskills.io/specification)
- 项目内：[AI_SKILL-03 技能制作规范](AI_SKILL-03-技能制作规范.md)、[AGENTS.md](../AGENTS.md) §3/§4、[03-27 版本升级指南](../topics/03-架构与运维实践/03-27-版本升级指南.md)、[02-17 死信队列设计](../topics/02-场景驱动架构设计/02-17-死信队列设计.md)

---

**最后更新**: 2026-11-18
