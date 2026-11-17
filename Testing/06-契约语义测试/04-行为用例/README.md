# 行为用例（04-行为用例/）

> L6 层：场景 × 系统 × 语义维度 → 可执行 TC。本目录当前为**骨架+样例**状态（dry-run 口径）：真实容器化执行（`--live`）需用户在场。
> 断言源：[../02-语义矩阵/semantics/assertions.tsv](../02-语义矩阵/semantics/assertions.tsv)（ASE-xxx，GWT）；场景输入：[../03-业务场景/](../03-业务场景/README.md)（contract.yaml invariants）。

## 结构

| 对象 | 形态 | 状态 |
| ---- | ---- | ---- |
| TC-BUS-01~08（父用例） | `tc-assert-check.sh` 静态校验（spec 解析/x-semantics 合法性/invariants 形式检查） | E0 第 7 步已纳入 |
| TC-SEM-05（死信） | [tc-sem-05-dlq-rabbitmq.sh](tc-sem-05-dlq-rabbitmq.sh)（ASE-007 族，E2，--live 门禁） | mapped，待真实首跑 |
| TC-SEM-07（背压） | [tc-sem-07-backpressure-nats.sh](tc-sem-07-backpressure-nats.sh)（ASE-010 族，E2，--live 门禁） | mapped，待真实首跑 |
| 其余 TC-SEM-01~12 | 断言库就绪，脚本随真实执行批次补全 | pending |

## 编写规则（与 TEST-11 L0-L3 对齐）

1. 默认 **dry-run**：脚本无 `--live` 只打印将执行的步骤与断言 ID，退出 0；`--live` 前必须过 `hermes-env-precheck.sh`。
2. 每个 FAIL 生成 failbundle（`hermes-collect-failbundle.sh`）并打诊断标签（`hermes-diagnose.sh`）。
3. 断言失败处置：L3（用例断言/文档类）走 `hermes-self-heal.sh` 审批单；环境类 L1/L2 走白名单。
4. 脚本头部注释必须列：关联 ASE id、关联场景包、环境、真实执行前置条件。

**最后更新**: 2026-11-18
