# AI_SKILL-07-测试与运维skill全面梳理

> **本文档定位**：对 Hermes Agent 技能库中「测试」与「运维」两个域的 skill 做全面梳理——分类、逐项核对（触发条件/核心流程/红线/互引）、缺口判定与自我改进执行记录。本目录 01~06 管「技能化方法论与规范」，本篇管「技能库本身的现状与改进」，不重写项目系统知识。
> **梳理范围**：Hermes 技能库全量 133 个 skill（26,625 chars）。其中测试域 12 个、运维域 9 个、交接与恢复域 2 个、调试与观测域 5 个，合计 28 个进入本篇；核心 7 个（run-all-verify / gates-regression-triage / dual-track-parallel-push / autonomous-loop-setup / session-handoff / empirical-change-verification / code-block-dryrun）已全文重载并逐项核对。
> **日期**：2026-11-20（批次169 H1 完成后）。

---

## 1. 判定标准

一个 skill 记为「可用」需同时满足四条：

1. SKILL.md 全文可读（frontmatter 完整、description ≤60 chars、有 When to Use）；
2. 触发条件明确（能由一句话请求命中，不依赖上下文猜测）；
3. 有红线/陷阱节（至少 3 条，且每条是「规则 + 原因」形态，非过程叙述）；
4. 互引关系成立（related_skills 指向真实存在的 skill；引用文件可达）。

缺口判定：某类可复现的工程流程，其关键判定（字段名、参数形态、失败签名）只能从会话记忆恢复、skill 库中无载体 → 记为缺口，需新建 skill 而非依赖记忆。

## 2. 分类总表

| 域 | skill | 触发场景（摘要） |
| --- | --- | --- |
| 测试·质量闭环 | run-all-verify | C_Lang `run_all.py` 失败后的五桶分诊与闭环 |
| 测试·质量闭环 | gates-regression-triage | `make gates` 新闸接线、基线内/外债务区分 |
| 测试·代码验证 | code-block-dryrun | 文档语料代码块逐块真实执行 + N-A 分类 |
| 测试·变更验证 | empirical-change-verification | Go 性能重构/守卫阈值提交前的一次性探针 |
| 测试·质量规范 | host-vs-target-testing | 主机模拟/单元测试与目标机测试的分层决策 |
| 测试·质量规范 | unit-test-unity | C 单元测试（Unity/CMocka）结构与断言纪律 |
| 测试·质量规范 | static-analysis-pipeline | 静态分析 CI 构建与阈值治理 |
| 测试·质量规范 | misra-compliance | MISRA C（2012/修订）建立与审计 |
| 测试·质量规范 | c-cert-checklist | SEI CERT C 规则评审 |
| 测试·回归基准 | golden-snapshot-regression | CLI 脚本输出的黄金快照回归 |
| 测试·形式化 | spark-gnatprove-pipeline | GNATprove 证明在本机的执行路由 |
| 测试·版本探测 | pg-major-version-probe | 版本守卫的 PG 升级 SQL 探测套件 |
| 测试·审计 | pgmodern-verification-audit | PostgreSQL_modern 验证终值梳理与批跑 |
| 测试·审计 | citation-anchor-verification | 参考与外部锚点节的添加核验 |
| 测试·审计 | kb-quiz-authoring | KB 概念页测验节的编写审计 |
| 运维·并行推进 | dual-track-parallel-push | CPU/GPU 双轨：后台长任务 + 会话内持续产出 |
| 运维·循环编排 | autonomous-loop-setup | cron 循环自建：队列权威文件 + 自包含 prompt |
| 运维·交接恢复 | session-handoff | 会话切换/中断前的状态保存与机械恢复 |
| 运维·事件驱动 | webhook-subscriptions | 事件驱动的外部任务触发 |
| 运维·MCP | native-mcp | MCP server 接入（stdio/HTTP） |
| 运维·本地服务 | comfyui-gpu-window | ComfyUI GPU 窗口的本地运行 |
| 运维·本地服务 | windows-local-postgres | 本机 PostgreSQL 运行与故障修复 |
| 运维·会话治理 | session-librarian | 会话按主题查找/重命名/归档 |
| 调试·观测 | debugging-hermes-tui-commands | Hermes TUI 斜杠命令调试 |
| 调试·观测 | inspecting-hermes-desktop-dom | 桌面 DOM/CSS 经 CDP 读取 |
| 调试·观测 | node-inspect-debugger | Node.js --inspect + CDP CLI 调试 |
| 交接·恢复 | session-handoff | （见上） |
| 交接·恢复 | merge-reconciler | 多 agent 合并冲突的中立仲裁 |

## 3. 核心 7 项逐项核对

### 3.1 run-all-verify（quality，C_Lang 仓内）

- 触发：`Testing/run_all.py` 非零退出或 fail≥1。
- 核心流程：取 fail 层级 → 逐用例归五桶（COMPILE / ASSERT / LINK / FIXTURE-DATA / TOOLCHAIN-SKIP-误标）→ 修正只允许四域 → 全量复跑 exit 0 方为闭环。
- 红线：禁改断言迁就实现、禁删 xfail、禁改 golden vectors、禁为变绿加 EXPECTED_FAIL。
- 互引：misra-compliance、c23-migration；接口契约 `AI_Skill_Spec/specs/RUN_ALL_VERIFY_INTERFACE.md` 为唯一权威。
- 判定：可用。语义受 C_Lang 仓接口契约约束，本篇不变更其语义。

### 3.2 gates-regression-triage（quality+systems，C_Lang 仓内）

- 触发：新 gate 接入 `make gates`，或新闸接线后出现回归。
- 核心流程：预跑全量 → 末尾追加接线（保持 14 闸顺序）→ 只修基线外债务（基线内登记不动）→ 四跑收敛 RC=0。
- 红线：基线内违规当 FAIL 处理（人为收缩基线）；批量修复不原子（truncate 后 crash 留零字节文件）；新闸未钉版即接线。
- 判定：可用。B 维（规模快照）与 E 维（BACKLOG 双状态）的冲突核对是与其他仓门控复用的通用方法。

### 3.3 dual-track-parallel-push（autonomous-ai-agents）

- 触发：后台长任务（编译/门控/批验）运行中，用户要求持续推进不干等。
- 核心流程：CPU 轨=后台进程（notify=true），GPU 轨=读码/分析/写补丁/回写台账；批开始先出编号任务表；10 分钟三问自检；批末一次性合并确认。
- 红线（已登记且本次批次验证有效的条目）：
  - 健康检查是门控不是任务——重复同一检查直到耗尽迭代预算、待办动作永远不执行，是回合死亡形态；
  - `cmd|tail; echo $?` 取的是 tail 的 RC，门控真值在日志 RC 行；
  - 启动宣告必须与真实启动调用+验证同回合，否则「实例」只存在于聊天；
  - Windows 后台启动用绝对解释器路径；禁 nohup 包装（包装退出码不是任务退出码）;
  - web_search 单回合硬上限 50，批前必核本回合累计数；搜索结果须同回合落盘 TSV。
- 判定：可用，无需修改。本次 Mq 批次的健康检查/启动纪律均由本 skill 覆盖。

### 3.4 autonomous-loop-setup（autonomous-ai-agents）

- 触发：用户要求「创建 N 分钟定时任务持续推进」。
- 核心流程：读仓治理 → 全量任务盘点（可执行/日历门/环境门/用户门四类）→ 建唯一队列权威文件（6 节结构，落仓不落 scratch）→ 注册 cron（自包含 prompt 含全红线）→ 设置本身独立提交。
- 红线：第二队列权威会分叉循环；主会话驱动拓扑下主会话是心跳唯一写者（哨兵只读）；台账汇总行必须程序重算不手增；cron job ID 跨会话漂移须按 list 重新匹配。
- 判定：可用。含 monitor-gated 变体（外部信号监视至日历门开启）与冷却恢复变体。

### 3.5 session-handoff（Handoff/Recovery）

- 触发：「保存下上下文 我准备切换」「我睡觉了」等切换/中断前请求。
- 核心流程：快照在途（git 三查 + 后台作业 + scratch 脚本清单）→ 仓内耐久位置写日期化交接文件（断点/队列/证据/下一会话命令 verbatim）→ scratch 脚本拷入仓（24h 剪除风险）→ 记忆锚点更新 → 紧凑确认表。
- 红线：交接文件不得内嵌包含自身提交的 SHA；未验证项必须标注为推断；交接时用户不耐烦，冗长总结即失败形态。
- Loop-Stop 变体（循环运行中切换任务）：先删定时器（list→remove→复列 count=0）→ 就地重写状态权威卡 → 队列对账实态 → 两批有序提交（先推在途、再推交接文档）。
- 判定：可用，无需修改。

### 3.6 empirical-change-verification（software-development，Go）

- 触发：Go 性能重构声称「行为不变」要提交，或提出守卫/阈值要实施。
- 核心流程：一次性探针（包内 `*_test.go`，真实语料）先行 → 等价证明（旧算法参考副本 + 签名函数 + 输入矩阵）或可行性预探针（候选信号双类分布 + 可分性）→ 负结果也是交付物 → 探针文件提交前删除、数值冻结进报告。
- 红线：等价≠性能，两者都需；辅助计数器是静默漂移藏身处；「合理」的启发式可能方向性错误，必须实测。
- 判定：可用。Go 域专用，其「探针先于提交、探针不入提交」原则可推广。

### 3.7 code-block-dryrun（代码块干跑验证）

- 触发：文档语料数百至数千围栏代码块需对真实运行时逐块验证；或批跑后残差分诊；或捕获层事故后重建。
- 核心流程：抽取（源路径+块索引头=join key）→ 沙箱逐块执行（SQL 单事务 ROLLBACK / go build / cargo build）→ 通过判据=进程 rc 唯一（不从输出文本推导）→ stderr 分类 → N-A 规则（新规则必须对已知通过基线 0 误报）→ 残差逐块裁决（doc-fix 需单块复跑 rc=0 证明，或 N-A 书面依据）→ 台账 + 终验文件 → 收束时重跑 harness 取真剩余数。
- 红线：捕获层污染→重跑不补记录；本地化错误文本须先提取引号内 token；`*.jsonl` 可能是单 JSON 数组；数字块 ID 经 JSON 变 int 须归一。
- 判定：可用。其「rc 唯一判据 + N-A 0 误报硬门 + 逐块裁决」三件是全部代码块验证任务的通用骨架。

## 4. 关联测试/运维 skill 清单

上表 2.1~2.28 中未入核心 7 项的 21 个，按域归并后要点：

- **质量规范四件**（host-vs-target-testing / unit-test-unity / static-analysis-pipeline / misra-compliance / c-cert-checklist）：C/嵌入式域的测试分层与规范审计，与 C_Lang、硬件仓配套，触发条件均明确，判定可用。
- **回归基准**（golden-snapshot-regression / spark-gnatprove-pipeline / pg-major-version-probe）：各自绑定具体运行时（CLI 输出/GNATprove/PG 版本探测），触发明确。
- **审计三件**（pgmodern-verification-audit / citation-anchor-verification / kb-quiz-authoring）：面向 KB 语料仓的专项审计，与对应仓的台账配套。
- **运维五件**（webhook-subscriptions / native-mcp / comfyui-gpu-window / windows-local-postgres / session-librarian）：本地服务与事件驱动，触发明确。
- **调试三件**（debugging-hermes-tui-commands / inspecting-hermes-desktop-dom / node-inspect-debugger）：Hermes 自身与 Node 调试，触发明确。
- **交接恢复两件**（session-handoff / merge-reconciler）：见 3.5 与多 agent 合并仲裁。

## 5. 缺口判定（本次批次证据）

| 编号 | 缺口 | 证据（本次批次实踩） | 处置 |
| --- | --- | --- | --- |
| G1 | Microcks+Kafka 异步契约测试流程无 skill 载体 | 批次169 四项根因全部从源码与容器实态推得：①minion `auto.offset.reset="latest"` 致消费 0 条，须 `?startOffset=0`；②spec `operations.<id>` 缺 `messages` 数组 + payload 非标准 JSON Schema 致 `messagePathPointer` 校验失败；③1.15.0 `TestRequestDTO` 字段为 `testEndpoint`（`endpoint` 被忽略→null→inProgress 300s）；④endpoint 须用容器内 INTERNAL `:29092`。以上判定仅存于会话记忆与 `results/2026-11-20/h1-microcks-evidence.md`，skill 库无载体 | 新建 `microcks-async-contract-test`（quality 域） |
| G2 | podman machine（WSL2）长任务稳定性无 skill 载体 | 2026-10-29 实测：podman machine 一小时内两次意外停机（VM 仅用 1.3GB，非 OOM，原因未定，疑 WSL 24.04.4 镜像代际不稳）；长稳任务须按「machine 会再挂」设计（断点续跑+双心跳+不与批量 dry-run 并行）。该判定仅存于记忆 | 新建 `podman-wsl2-stability` |
| G3 | dual-track-parallel-push 是否缺「健康检查重复」陷阱 | 核对结果：该陷阱已登记（「A health check is a gate, not a task」节），且本次批次执行中有效 | 无修改 |
| G4 | session-handoff 是否缺循环中切换变体 | 核对结果：Loop-Stop 变体已完整（删定时器→就地重写权威卡→队列对账→两批提交） | 无修改 |

## 6. 自我改进执行记录

| 动作 | 对象 | 类型 | 状态 |
| --- | --- | --- | --- |
| 新建 skill | `microcks-async-contract-test`（quality） | 缺口 G1 | 已创建 |
| 新建 skill | `podman-wsl2-stability`（本地服务运维） | 缺口 G2 | 已创建 |
| 修订既有 skill | 核心 7 项 | 逐项核对 | 0 处需修订（G3/G4 判定见上） |
| 台账回写 | 本篇 + AI_Skills/README 系列文档表 | 登记 | 已登记 |

## 7. 边界声明

- run-all-verify 与 gates-regression-triage 两个 skill 的文件位于 C_Lang 仓 `AI_Skill_Spec/skills/`，语义由该仓接口契约治理；本篇只做可达性与结构核对，不变更其内容。
- 本仓 `AI_Skills/skills/` 下 7 个 mq-* 技能是项目域技能（选型/死信/升级/MQTT/NATS/文档 lint），与 Hermes 技能库为两套体系，不在本篇范围；其审计由 AI_SKILL-06 治理。
- 缺口判定只覆盖「测试」与「运维」两域；其他域（创意/研究/协议/硬件）的 skill 现状不在本篇。
