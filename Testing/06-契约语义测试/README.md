# 契约语义测试（Contract & Semantic Testing）

> 顶层主题文件夹（与 Testing/、AI_Skills/、topics/ 平级，2026-11-18 设立）。
> 主题：把项目的 DSL/契约知识层（批次 34-39）测试化——DSL → AsyncAPI → MQ 绑定 → 通信语义 → 业务场景 → 行为用例 六层模型。
> 总纲与批次规划见 [00-模型与规划/TEST-C1-六层契约语义测试模型与规划.md](00-模型与规划/TEST-C1-六层契约语义测试模型与规划.md)。

## 目录结构

| 目录 | 层 | 内容 | 状态 |
| ---- | ---- | ---- | ---- |
| `00-模型与规划/` | — | TEST-13 六层模型总纲；TEST-14 语义矩阵（批次73）；TEST-15 场景规范（批次74） | TEST-13 ✅ |
| `01-契约规格/` | L1-L2 | 六系统 AsyncAPI spec（kafka/mqtt 沿用 config-templates，nats/amqp/pulsar/redis 本系列新建）+ 漂移检测 | 批次71 ✅ |
| `02-语义矩阵/` | L4 | 12 语义维度 × 六系统能力矩阵 + GWT 断言机读版 | 批次73 待执行 |
| `03-业务场景/` | L5 | 8 通用业务场景契约包（contract.yaml + asyncapi.yaml + SEMANTICS.md） | 批次74 待执行 |
| `04-行为用例/` | L6 | TC-SEM-xx / TC-BUS-xx 可执行用例脚本 | 批次75 待执行 |
| `05-追溯覆盖/` | — | 六层追溯表 + 覆盖率报告 | 批次76 待执行 |

## 命令速查

```bash
# L1-L2 契约静态校验（E0 已纳入，每次提交自动执行）
bash topics/scripts/contract-spec-check.sh          # 六 spec 结构校验
bash topics/scripts/contract-drift-check.sh         # spec↔config-templates 漂移检测
# 语义抽检（月度种子抽样，只读）
bash topics/scripts/doc-semantic-spotcheck.sh
# E0 全量静态验证（含契约步骤）
bash topics/scripts/hermes-e0-run.sh
```

## 边界约定

- **在 Testing 体系内的位置**：本目录是 Testing 第六子系列（契约与语义维度），统一编排见 [../00-规范与计划/TEST-00-测试体系总规划.md](../00-规范与计划/TEST-00-测试体系总规划.md)；编号用 TEST-C 前缀（C1 总纲/C2 语义矩阵/C3 场景规范），与 00~05 子系列的 TEST 编号不冲突。
- **与 topics/**：知识论证（是什么）在 topics（01-43/44、02-56/57、01-63~66）；本目录是其可执行验证（对不对）。
- **与 topics/knowledge-graph/**：机读概念图谱（kg-check 入 E0 第 8 步）是本目录 TEST-C2 语义矩阵的机读镜像。
- 真实容器化执行（E1/E2 实跑、混沌注入）需用户在场；平时以 E0 静态层 + harness --dry-run 为门禁。

---

**最后更新**: 2026-11-18
