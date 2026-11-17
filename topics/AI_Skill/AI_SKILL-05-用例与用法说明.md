# AIS.05 用例与用法说明

> **本文档定位**：项目 Agent Skills 的安装、装载、触发与使用效果说明，含 6 个标准用例回放脚本与评估方法。技能的制作规范见 AI_SKILL-03，模板见 AI_SKILL-04。

## 目录

- [AIS.05 用例与用法说明](#ais05-用例与用法说明)
  - [目录](#目录)
  - [AIS.05.1 安装与装载](#ais051-安装与装载)
  - [AIS.05.2 触发机制](#ais052-触发机制)
  - [AIS.05.3 标准用例集](#ais053-标准用例集)
  - [AIS.05.4 使用效果评估方法](#ais054-使用效果评估方法)
  - [AIS.05.5 常见问题](#ais055-常见问题)
  - [AIS.05.6 参考来源](#ais056-参考来源)

---

## AIS.05.1 安装与装载

Agent Skills 是"目录即技能"：把技能文件夹放到平台约定的发现路径即可，无构建步骤。各平台路径（2026-11 核实，随平台版本演进请复查）：

| 平台 | 个人级路径 | 项目级路径 | 说明 |
| ------ | ----------- | ----------- | ------ |
| Claude Code | `~/.claude/skills/<skill>/` | `<repo>/.claude/skills/<skill>/` | 原生支持；亦可经 plugin marketplace 安装 |
| OpenAI Codex CLI | `~/.codex/skills/<skill>/` | 仓库内约定目录 | 声明"build on the open agent skills standard" |
| GitHub Copilot / VS Code | — | 项目文件夹内 SKILL.md（与 Claude Code 共用 `.claude/skills`） | 2026-01 起稳定版支持 |
| Cursor | `~/.cursor/skills/<skill>/` | 项目 `.cursor/skills/`（随版本） | 支持 Agent Skills 格式 |
| Kimi Code 等中国 CLI | `C:/Users/<user>/.agents/skills/<skill>/`（Windows） | 项目 `.agents/skills/` | 技能目录装载（本仓库协作环境即此机制） |

```bash
# 通用装载三步（以项目级、Claude Code 为例）
mkdir -p .claude/skills
cp -r skills/mq-selection .claude/skills/        # 1. 复制技能目录
skills-ref validate .claude/skills/mq-selection  # 2. 校验（可选，推荐）
# 3. 重启 CLI 会话，技能随描述自动进入发现列表
```

项目级装载的建议：技能源统一放 `skills/` 目录纳管，装载用符号链接或 CI 拷贝，避免在 `.claude/skills` 里产生无人维护的副本。

## AIS.05.2 触发机制

三种触发方式（按可靠性从高到低）：

1. **显式调用**：`/mq-selection` 或 `Skill(skill="mq-selection")`——确定性强，适合演示与评审。
2. **描述自动激活**：用户请求与 description 中触发关键词命中时由 Agent 自动装载——日常使用主力，因此 description 写作是质量第一指标（AI_SKILL-03 AIS.03.3）。
3. **流水线预载**：子代理/CI 任务中按名预载（Claude Code 支持向 subagent 注入技能）。

**触发诊断**：技能没自动激活时，先查 description 是否含用户原话关键词（中英都查），再查 name 与目录名一致性（不一致会装载失败），最后用 `skills-ref validate` 排除 frontmatter 非法。

## AIS.05.3 标准用例集

每个技能交付前须回放以下对应用例；用例同时是验收证据（AI_SKILL-03 AIS.03.8）。

| 用例 | 用户输入（触发样例） | 期望激活技能 | 验收要点 |
| ------ | ---------------------- | -------------- | ---------- |
| U1 选型 | "日志采集场景选 Kafka 还是 Pulsar？要给论证" | mq-selection | 输出含决策树路径、对比表指针、置信标注；约束不足时先反问 |
| U2 DLQ 论证 | "RabbitMQ 死信队列怎么设计？和 Kafka 比呢" | mq-pattern-dlq | 六系统对比 + 方案组合 + 引至 mq-ops-dlq |
| U3 升级操作 | "帮我把 Kafka 从 3.8 升到 4.1" | mq-ops-kafka-upgrade | 前置检查→步骤→每步验证→回滚边界齐全 |
| U4 系统问答 | "NATS JetStream 的 KV 和 ObjectStore 什么区别" | mq-nats-deep-dive | 引 01-26 事实，标注时效，不乱编版本号 |
| U5 容量规划 | "日增 10 亿条消息，Kafka 集群怎么规划" | mq-capacity-plan（D4） | 给计算过程 + 【估算】标注 + 指向 03-57 |
| U6 治理自检 | "检查全库文档是否符合 AGENTS.md 规范" | mq-doc-lint | 实际执行 doc-self-check.sh 并解读 FAIL/WARN |

用例回放记录格式（附在 PR/批次说明中）：

```text
[U3 回放] 2026-11-17 kimi-code
输入: "帮我把 Kafka 从 3.8 升到 4.1"
激活: mq-ops-kafka-upgrade（显式 /mq-ops-kafka-upgrade）
结果: 前置检查 3/3 通过；步骤含 KRaft 验证命令；回滚边界正确指向
     version-facts.md；token 消耗 4.1k（预算内）
结论: PASS
```

U1（选型）完整回放示例——展示"约束不足先反问"的红线行为：

```text
[U1 回放] 2026-11-17
输入: "我们该用什么消息队列？"
技能: mq-selection 自动激活（命中"技术选型/消息队列"触发词）
执行:
  1. 识别硬约束缺失 → 反问 4 项：峰值吞吐/延迟要求/是否要求顺序与事务/
     运维成本上限
  2. 用户补充: 10 万 msg/s、P99 < 50ms、需要顺序、2 人运维
  3. 查 decision-tree → 候选 Kafka / Pulsar
  4. 查 selection-matrix：运维成本列 → Kafka 社区生态占优【论证】
输出: 推荐 Kafka（RF=3, min.insync=2 基线）+ 备选 Pulsar（存算分离利于
     未来扩容）+ 指向 mq-test-deploy-cases 验证建议
结论: PASS（反问行为符合红线；置信标注完整）
```

U2（DLQ 论证）回放要点：检查技能是否先给"六系统机制对比"再给方案（而非直接拍脑袋推荐 RabbitMQ DLX）；输出末尾必须互链 `mq-ops-dlq`。U5（容量规划）回放要点：要求技能展示计算过程（峰值 msg/s × 消息大小 × 副本数 → 磁盘/带宽估算），结论数字标【估算】，并指向 03-57 与 mq-test-cluster-cases 做压测验证——不展示计算过程的容量建议一律判 FAIL。

U4（系统问答）与 U6（治理自检）回放要点：

```text
[U4 回放要点]
- 回答必须标注时效（"核实至 2026-11"），涉及版本号时给出源链接
- 对 references 中没有的事实（如未收录的 newest 版本）应明示"超出知识范围"
  而非编造 —— 此条为 FAIL 红线
[U6 回放要点]
- 技能须真实执行 doc-self-check.sh 而非复述检查项
- 输出解读须区分 ERROR/WARN 并给出对应处置路径（TEST-05 分类）
```

## AIS.05.4 使用效果评估方法

对技能做"有无对比"评估，避免"装了感觉不错"式主观结论：

| 指标 | 测量方法 | 参考目标 |
| ------ | ---------- | ---------- |
| 激活准确率 | 用 20 条真实问题测试集统计"该激活时激活 / 不该激活时不激活" | 激活率 ≥ 90%，误激活 ≤ 5% |
| 回答事实准确率 | 抽检 10 次回答与源文档逐条核对 | 事实错误 0 条；时效错误 0 条 |
| Token 开销 | 会话日志统计技能激活额外消耗 | L2 装载 < 5000 tokens/次 |
| 任务完成时延 | 同类任务有/无技能各 5 次计时 | 有技能显著省时（定性即可） |
| 用户修正率 | 用户指出"答非所问/事实错"次数占比 | 逐次归因并回写 references |

评估结论记入技能 `metadata`（如 `metadata.eval: "2026-11-17 act=0.92"`），两次评估不达标即降级 `metadata.status: stale` 并回炉。

技能版本管理约定：技能版本独立于项目版本，语义化 `major.minor.patch`——major 为范围变更（触发词/结构大变），minor 为内容增强（references 扩充），patch 为修正（事实错误、时效更新）；技能版本变化记入 CHANGELOG 的技能小节，与文档版本条目分开列。

团队 rollout 建议路径（从个人到组织）：

1. 个人试用：装载至个人级路径，自用 1 周收集触发失败案例；
2. 项目共享：合入仓库 `skills/` 并项目级装载，批次评审时过 AI_SKILL-03 清单；
3. 团队规范：纳入新人 Onboarding 与 AGENTS.md 引用，成为默认工作方式；
4. 对外发布：差异化技能（国际空白项）可单独开源发布，反哺社区并引流项目。

使用反馈的回收渠道：触发失败案例（该激活未激活/误激活）与事实错误指正，记入技能的 `metadata.eval-note` 并在下次评估时回放；累积 5 条以上同类反馈即触发该技能的 references 修订，不等到季度评估。

批量回放记录模板（一个批次验收多个技能时使用）：

```text
# 批次技能验收回放（YYYY-MM-DD）
| 技能 | 用例 | 激活方式 | 结果 | token | 备注 |
| mq-selection | U1 | 自动 | PASS | 3.8k | 反问行为正确 |
| mq-ops-kafka-upgrade | U3 | 显式 | PASS | 4.1k | 回滚边界正确 |
| mq-pattern-dlq | U2 | 自动 | FAIL→修复后PASS | 5.2k | 首漏互链 mq-ops-dlq，已补 |
结论: 3/3 通过（1 次退回），批次可收尾
```

## AIS.05.5 常见问题

**Q1：同一个技能能在多个 Agent 平台用吗？**
符合开放规范即可（AI_SKILL-01 AIS.01.4 平台表）。注意 `allowed-tools` 是实验字段，不要在不同平台间做行为强假设。

**Q2：技能和项目文档会不会不一致？**
会，这是派生物天然风险。对策是 AIS.02.5 的 five 件套：溯源标注、--skill-drift 对账、时效继承、置信继承、失效下线。

**Q3：可以直接用 Lenses/skillsdirectory 的现成 MQ 技能吗？**
可以但先过 AIS.03.7 安全审查四级；且注意其英文语料与版本时效未必覆盖 Kafka 4.x/中文场景，项目自制技能负责补齐差异（AI_SKILL-02 AIS.02.3）。

**Q4：技能里能直接跑项目 scripts/ 的脚本吗？**
建议复制到技能 `scripts/` 目录并标注来源（相对路径引用在项目外装载时不可用）；脚本必须 `set -e` 且 dry-run 友好。

**Q5：一个团队如何分发技能？**
仓库内 `skills/` 纳管 + 项目级 `.claude/skills` 装载 + 版本锁（CHANGELOG 记技能变更）；跨仓库分发走内部 marketplace 或 git submodule。

装载故障排查速查表：

| 症状 | 可能原因 | 排查命令/动作 |
| ------ | ---------- | ---------------- |
| `/技能名` 无响应 | 目录未放入发现路径 | 核对 `.claude/skills/` 等平台路径 |
| 装载但从不自动激活 | description 缺触发关键词 | 用 AI_SKILL-03 AIS.03.3 模板改写后复测 |
| 激活但正文行为异常 | frontmatter 非法被平台忽略 | `skills-ref validate` 或 head -1 检查 `---` |
| 引用的 references 找不到 | 引用超出一层深度或文件名错 | 检查相对路径与大小写（Linux 严格区分） |
| 更新技能后行为没变 | 平台缓存了旧描述 | 重启会话；必要时清平台技能缓存目录 |

使用本系列文档的顺序建议：直接使用者从 AIS.05.3 用例集找场景按图索骥；制作新技能者按 AIS.03 → AIS.04 的顺序执行，并在交付前完成 AIS.05.4 的评估记录。

## AIS.05.6 参考来源

- [Agent Skills 开放规范](https://agentskills.io/specification)（装载与渐进披露语义）
- [Claude Platform Skills 文档](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [OpenAI Codex Skills 文档](https://developers.openai.com/codex/skills/)
- [Microsoft Agent Framework Skills](https://learn.microsoft.com/en-us/agent-framework/agents/skills)
- 项目内：[AI_SKILL-02 图谱](AI_SKILL-02-项目主题技能图谱.md)、[AI_SKILL-03 规范](AI_SKILL-03-技能制作规范.md)、[TEST-06 自我验证机制](../Testing/TEST-06-自我验证机制与脚本说明.md)

---

**最后更新**: 2026-11-17
