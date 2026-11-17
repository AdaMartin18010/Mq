# T.13 用例漂移与更新机制（Testing 体系）

> **置信口径**: 机制设计=【论证】；工具行为以官方文档为准。
> **时效声明**: 核实至 2026-11。
> **本文档定位**: 批次 67 落地文档。定义用例注册表状态机、三类漂移触发链与处置流程。与 TEST-09 任务包、TEST-11 自愈分级、契约语义测试 traceability 联动。

## 目录

- [T.13 用例漂移与更新机制（Testing 体系）](#t13-用例漂移与更新机制testing-体系)
  - [目录](#目录)
  - [T.13.1 用例状态机](#t131-用例状态机)
  - [T.13.2 三类漂移触发链](#t132-三类漂移触发链)
  - [T.13.3 处置与升级规则](#t133-处置与升级规则)
  - [T.13.4 基准回灌流程](#t134-基准回灌流程)

---

## T.13.1 用例状态机

test-registry.tsv `status` 列取值与流转：

```text
pending  --脚本绑定+静态校验通过-->  mapped  --首次真实执行通过-->  verified
   ▲                                │                              │
   │                                │ 脚本失效/文件缺失             │ 连续 3 次失败
   │                                ▼                              ▼
   └──────────────  quarantined（隔离区，暂停执行，周会评审）  <────┘
deprecated：用例废弃（功能删除/被替代），保留行不删除（历史可追溯）
blocked：  外部依赖长期不可用（如 E3 集群缺席），恢复后回 pending
```

- `mapped` 准入条件：script 列指向的脚本实地存在 + `bash -n` 通过 + E0 registry 校验通过（批次 66 的 TC-INT-09/10b/10c 反例：无脚本不得停留 mapped）。
- `verified` 需产物证据：results/<date>/ 下对应 case JSON + log（T.09.5 五字段）。

## T.13.2 三类漂移触发链

| 漂移类型 | 检测器 | 链路 | 影响面 |
| ---- | ---- | ---- | ---- |
| **文档漂移** | `hermes-task-gen.sh --drift <文件>` | 文档变更 → doc_refs 命中的用例 ID 列表 → 加入下次 nightly/weekly 任务包 | topics/ 任意 md |
| **契约漂移** | `contract-drift-check.sh --format=ids` | spec/模板参数不一致 → spec 文件名列表 → Microcks test 重跑 + TC-BUS 父用例重检 | 契约语义测试/01-契约规格/ |
| **版本漂移** | ROADMAP 版本追踪清单人工变更 → `hermes-task-gen.sh --drift 01-XX,03-XX` | 大版本 GA（如 Kafka 4.5）→ 30 天内更新对应专章（ROADMAP 例行规则）→ 该专章 doc_refs 用例全量重跑 | 八系统专章 |

触发器执行频率：文档/契约漂移 = 每次提交（E0 内嵌静态层）；版本漂移 = 季度复核（TEST-06 月度回顾时扫描一次版本清单）。

## T.13.3 处置与升级规则

1. 漂移命中用例重跑失败 → 按 TEST-11 归因分类（P/E/D/T/B）→ 走自愈分级（L0 报告 / L1 清理重跑 / L2 配置修复 / L3 人工）。
2. 同一用例连续 3 次漂移重跑失败 → 自动置 quarantined（人工执行 `sed` 改状态并记录于 Testing/self-check-history.log 备注列）。
3. quarantined 用例不参与通过率分母（缺口率单独统计，防止"隔离=掩盖"）。
4. 每季度评审 quarantined 清单：修复回归 / 转 deprecated / 维持隔离，三选一。

## T.13.4 基准回灌流程

实测数字进入文档替换【估算】的完整链（03-66 指南的治理化）：

```text
E2 执行 OpenMessaging Benchmark（03-66 命令清单）
  → 结果填 Testing/fixtures/benchmark-result-template.md（commit/workload/环境/日期 四元组）
  → L3 审批（hermes-self-heal.sh 生成审批单）：数字、口径、置信区间三人复核
  → 回灌目标文档（改【估算】→ 实测值+来源标注）
  → doc-self-check full 回归 + 同参数名联动修正（grep 全库）
  → CHANGELOG 记一条"基准回灌"条目
```

当前挂账：首个真实基准执行（Kafka vs NATS 小规模）待用户在场批次（ROADMAP"待办挂账"）。

---

**最后更新**: 2026-11-18
