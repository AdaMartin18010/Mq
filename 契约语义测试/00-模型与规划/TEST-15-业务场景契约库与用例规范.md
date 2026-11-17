# T.15 业务场景契约库与用例规范

> **置信口径**: 契约组织方法=【论证】；字段级语义=【定理】/【论证】按引用源。
> **时效声明**: 核实至 2026-11。
> **本文档定位**: L5 层规范。定义业务场景契约包的文件结构、编写规则、评审清单与 TC-BUS 用例生成规则。[03-业务场景/](../03-业务场景/README.md) 8 个场景包是本规范的首批实例。

## 目录

- [T.15 业务场景契约库与用例规范](#t15-业务场景契约库与用例规范)
  - [目录](#目录)
  - [T.15.1 场景包三文件结构](#t151-场景包三文件结构)
  - [T.15.2 编写规则](#t152-编写规则)
  - [T.15.3 评审清单](#t153-评审清单)
  - [T.15.4 TC-BUS 用例生成规则](#t154-tc-bus-用例生成规则)
  - [T.15.5 与 TEST-12 的衔接](#t155-与-test-12-的衔接)

---

## T.15.1 场景包三文件结构

| 文件 | 内容 | 约束 |
| ---- | ---- | ---- |
| `contract.yaml` | 场景 DSL：消息定义（命令/事件/查询三类）、状态机（如有）、invariants 断言 | 字段含 type/desc；invariants 必须可判定（真/假） |
| `asyncapi.yaml` | spec：servers/channels/operations/components；`x-semantics` 标注 | 结构通过 contract-spec-check；payload `$ref` 指回 contract.yaml |
| `SEMANTICS.md` | 语义标注表（维度→理由→消息→GWT 关注点）+ 设计陷阱 + 互链 | 维度名逐字取 TEST-14 清单；≥1 条陷阱 |

## T.15.2 编写规则

1. **消息三分**：每条消息必须标注 command/event/query 之一；命令必带幂等键，事件必带 occurredAt 类时间戳，查询必带响应地址（02-57）。
2. **invariants 可测**：不变式写成败者可脚本断言的形式（"至多一次"/"单调有序"/"不为负"），禁止"应当合理"式空话。
3. **claim-check 优先**：payload 大于 ~4KB 或大对象一律传引用（contentRef/payloadRef），与 02-19 衔接。
4. **x-semantics 标注在 operation 级**：一个 operation 只标注它真实依赖的维度；维度取舍理由写进 SEMANTICS.md。
5. **主系统选择**：选该场景语义矩阵 ●/◐ 格最多的系统，避免 ○ 格堆应用层补偿。

## T.15.3 评审清单

- [ ] contract.yaml 可被 python3 yaml 解析；asyncapi.yaml 通过 contract-spec-check.sh
- [ ] 每条命令消息有 idempotency-key 头；每个 invariant 有对应 GWT 关注点在 SEMANTICS.md
- [ ] x-semantics 值 ∈ TEST-14 十二维度清单（逐字）
- [ ] 复用检查：信封结构与 config-templates 现有模板重复率 = 0（引用不复制）
- [ ] SEMANTICS.md 至少 1 条"设计陷阱"，且与互链文档不重复

## T.15.4 TC-BUS 用例生成规则

- 每场景至少生成 1 个父用例 `TC-BUS-<场景NN>`（契约静态校验：spec 解析 + invariants 形式检查 + x-semantics 合法性）→ 入 E0 链；
- 每场景对主系统生成 ≥1 个执行用例 `TC-BUS-<场景NN>-<系统>`（E1/E2 行为断言，输入 = contract.yaml invariants + assertions.tsv 同维度断言）；
- 父用例状态 scripted 契约校验通过后可流转；执行用例真实运行需用户在场（dry-run 先行）。

## T.15.5 与 TEST-12 的衔接

[TEST-12](../../Testing/02-集成用例/TEST-12-企业应用场景端到端用例库.md) 的三场景（电商订单/金融转账/IoT 遥测）是端到端**用例视角**，本库是同领域的**契约视角**：用例引用契约包作为输入断言源（TEST-12 已加互链节），契约变更触发 TEST-12 用例的 drift 重跑（contract-drift-check.sh --format=ids → hermes-task-gen.sh --drift）。

---

**最后更新**: 2026-11-18
