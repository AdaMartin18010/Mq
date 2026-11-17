# T.13 六层契约语义测试模型与规划

> **置信口径**: 协议/规范语义=【定理】；架构与工程推理=【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1 P3 基线）。
> **时效声明**: 本文事实基于 AsyncAPI 官方规范/bindings 仓库与项目现有文档核实至 2026-11。
> **本文档定位**: Testing 第六子系列（06-语义与契约测试）总纲。定义"DSL→AsyncAPI→MQ 绑定→通信语义→业务场景→行为用例"六层测试模型、命名编号规范、与批次 64-76 的任务映射。不替代 TEST-02/03/04 的运维维度用例，与之正交互补。

## 目录

- [T.13 六层契约语义测试模型与规划](#t13-六层契约语义测试模型与规划)
  - [目录](#目录)
  - [T.13.1 成立背景：知识层完备、测试层空白](#t131-成立背景知识层完备测试层空白)
  - [T.13.2 六层模型定义](#t132-六层模型定义)
  - [T.13.3 命名与编号规范](#t133-命名与编号规范)
  - [T.13.4 批次 71-76 任务映射](#t134-批次-71-76-任务映射)
  - [T.13.5 与执行底座（批次 64-70）的关系](#t135-与执行底座批次-64-70的关系)
  - [T.13.6 与知识层（01-43/01-44/02-56/02-57）的互链](#t136-与知识层01-4301-4402-5602-57的互链)
  - [T.13.7 执行约定与人在回路边界](#t137-执行约定与人在回路边界)
  - [T.13.8 参考来源](#t138-参考来源)

---

## T.13.1 成立背景：知识层完备、测试层空白

项目的 DSL/契约**知识层**已于批次 34-39 建成：01-43（设计→DSL 转换方法论）、01-44（DSL 表达力边界与等价转换）、02-56（Spec-Driven 体系）、02-57（IT 通用契约模式库）、01-45/01-46（领域消息标准）。这些文档回答了"**是什么**"。

但**测试层**长期空白，三则证据：

1. 用例注册表（topics/scripts/test-registry.tsv，131 行）的域分布只有 CHK/DEP/INT/CLU/OBS/CON——**没有 SEM（通信语义）域，没有 BUS（业务契约）域**；
2. 全库检索"语义测试/通信层语义"零命中；
3. 现有 DEP/INT/CLU 用例全部验证"系统能否部署/集群能否成形/指标能否抓取"（运维维度），**没有任何一条验证"消息流是否遵守契约"或"业务场景行为是否正确"**。

一句话：知识库证明了"这些系统/语义/场景是什么"，测试体系还不能证明"系统真的遵守了契约和语义"。本子系列补齐后者。

## T.13.2 六层模型定义

```text
L1 DSL 契约层    contract.yaml（场景 DSL）+ 项目契约模板
     ↓ 测试化：契约静态校验、漂移检测
L2 AsyncAPI 层   asyncapi.yaml（spec：channels/operations/messages/bindings）
     ↓ 测试化：spec 结构合法性、binding 支持矩阵
L3 MQ 绑定层     spec bindings ↔ config-templates ↔ 六系统实际配置
     ↓ 测试化：绑定映射一致性校验（参数名/值域）
L4 通信语义层    12 语义维度 × 六系统能力矩阵 + GWT 行为断言
     ↓ 测试化：语义矩阵机读化、断言注册 TC-SEM-xx
L5 业务场景层    8 通用业务场景 × 消息模式（契约包）
     ↓ 测试化：场景契约 x-semantics 标注、注册 TC-BUS-xx
L6 行为用例层    场景 × 系统 × 语义维度 → 可执行 TC 脚本
```

| 层 | 定义 | 已有资产 | 本子系列补齐 |
| ---- | ---- | ---- | ---- |
| L1 | 设计意图的形式化表达 | 01-43/01-44、02-53/02-54/02-56/02-57、config-templates 契约六模板 | contract.yaml 校验入 E0 |
| L2 | 跨语言/跨系统的契约描述标准 | 01-30/01-32/01-37、spectral-asyncapi-ruleset.yaml、kafka/mqtt 两 spec 示例 | specs/ 六系统全集 + contract-spec-check.sh |
| L3 | 契约到具体系统的绑定落地 | config-templates 58 模板、各系统部署文档 | 绑定矩阵 + contract-binding-check.sh |
| L4 | 消息通信的通用语义维度 | 01-63（EOS）/01-64（MQTT QoS）/01-65（DLQ）/01-66（背压）论证 | TEST-14 语义矩阵 + SEM 用例 |
| L5 | 通用业务场景的契约化组织 | TEST-12 三场景、02 系列场景设计 | scenarios/ 八场景契约库 |
| L6 | 可执行行为用例 | test-harness.sh、mq-smoke-test.sh、fixtures | TC-SEM/TC-BUS 脚本 + 追溯表 |

**L4 十二语义维度标准清单**（全系列逐字使用，禁止同义改写）：

交付语义、顺序性、幂等去重、重试退避、死信、事务、背压、TTL过期、延迟消息、消息过滤、流控、持久化。

## T.13.3 命名与编号规范

| 对象 | 规范 | 示例 |
| ---- | ---- | ---- |
| 系列目录 | 顶层 `契约语义测试/`（与 Testing/、AI_Skills/、topics/ 平级；Testing 内不另设子系列） | — |
| 规范文档 | 契约语义测试/00-模型与规划/TEST-13/14/15（Testing 编号序列延续） | 本文档 |
| 系统 spec | `01-契约规格/specs/asyncapi-<system>-example.yaml`（system ∈ kafka/mqtt/nats/amqp/pulsar/redis） | specs/asyncapi-nats-example.yaml |
| 场景契约包 | `03-业务场景/<NN>-<name>/`（NN=01~08），含 contract.yaml / asyncapi.yaml / SEMANTICS.md | 03-业务场景/01-order-lifecycle/ |
| 语义用例 | TC-SEM-NN（NN=01~，按 12 维度×系统展开） | TC-SEM-01 |
| 业务用例 | TC-BUS-<场景NN>-<系统> | TC-BUS-01-KAFKA |
| 校验脚本 | topics/scripts/contract-*-check.sh | contract-spec-check.sh |
| registry 域 | SEM / BUS（新增两域，与 DEP/INT/CLU/OBS/SEC/CON/CHK 并列） | — |
| 运行产物 | results/（仓库根，.gitignore 已排除） | — |

## T.13.4 批次 71-76 任务映射

| 批次 | 任务 | 关键产出 | 验收标准 |
| ---- | ---- | ---- | ---- |
| 71 | L1-L2 契约静态测试层 | specs/ 补 4 系统 spec、spectral 规则可执行化、漂移检测、E0 增契约步骤 | spec-check 6/6 PASS；E0 六步全绿 |
| 72 | L3 MQ 绑定映射验证 | 六系统 bindings 矩阵（WebSearch 核实）、contract-binding-check.sh | 映射校验 0 冲突 |
| 73 | L4 通信语义矩阵 | TEST-14 文档（12 维×6 系统）、semantics/ 机读断言、registry +TC-SEM | 矩阵 72 格全覆盖、断言 GWT 可机读 |
| 74 | L5 业务场景契约库 | scenarios/ 八场景×3 文件、TEST-15 规范、TEST-12 互链节 | 8 场景 spec 全解析通过、语义标注齐全 |
| 75 | L6 行为用例 | ≥12 个 TC-SEM/TC-BUS 脚本骨架、weekly.yaml 扩员、registry 状态流转 | harness --dry-run 全量可解析 |
| 76 | 追溯与覆盖闭环 | traceability.md 六层追溯表、doc-coverage-check 语义维度扩展、四件套 | 追溯覆盖率 ≥85% |

## T.13.5 与执行底座（批次 64-70）的关系

批次 64-70 建设 hermes 执行底座：环境预检（hermes-env-precheck.sh，实测本机 E0/E1/E2 可用、E3 缺 kubectl）、E0 静态入口（hermes-e0-run.sh）、任务包生成器（hermes-task-gen.sh）、自愈分级（hermes-self-heal.sh，L0-L3）。

本子系列是该底座上的**内容层**：批次 71/72 的产物进入 E0（每次提交执行）；批次 75 的用例进入 weekly 任务包（E1/E2 周期执行）；所有 FAIL 走 TEST-11 的 diagnose→fix→heal→report 闭环。依赖关系：71/72/73/74 为纯静态产物可立即执行；75 依赖 66 的环境层结论（当前口径：**dry-run 绑定先行，真实容器运行由用户在场时执行**）；76 依赖 73/74/75 全部落地。

## T.13.6 与知识层（01-43/01-44/02-56/02-57）的互链

| 知识文档 | 测试层消费方式 |
| ---- | ---- |
| 01-43 设计→DSL 转换 | 场景 contract.yaml 的字段组织遵循其转换规则 |
| 01-44 表达力边界 | spec 中 DSL 表达不了的语义（编排/路由）一律 x- 扩展并登记，禁止在 spec 内写程序逻辑 |
| 02-56 Spec-Driven 体系 | 契约漂移检测（contract-drift-check.sh）落实其漂移检测要求 |
| 02-57 IT 通用契约模式库 | 场景契约复用其 envelope 模板（任务队列/CDC/Webhook），不重复造字段 |
| 01-63/01-64/01-65/01-66 | TEST-14 语义矩阵的论证引用源，矩阵只给结论+指针，不重复论证 |

## T.13.7 执行约定与人在回路边界

1. **dry-run 边界**：真实容器化执行（E1/E2 实跑、混沌注入）须用户在场；平时以 harness --dry-run + E0 静态层为门禁。
2. **L3 永不自动**：文档正文/用例断言/脚本的修复一律走 TEST-11 L3 审批单。
3. **产物隔离**：specs/scenarios/semantics 入库；运行产物入 results/（.gitignore 已排除）；审计入 Testing/hermes-audit.log。
4. **事实纪律**：bindings 支持现状等版本事实必须 WebSearch 官方核实（asyncapi/bindings 仓库），禁止凭记忆写。
5. **每批四件套**：CHANGELOG / INDEX / PROJECT_STATUS / ROADMAP 同步登记。

## T.13.8 参考来源

- 项目内：[TEST-09](../../Testing/00-规范与计划/TEST-09-测试执行计划与环境矩阵.md)、[TEST-11](../../Testing/00-规范与计划/TEST-11-hermes自治执行与自愈排障体系.md)、[TEST-12](../../Testing/02-集成用例/TEST-12-企业应用场景端到端用例库.md)、[01-43](../../topics/01-基础概念与对比分析/01-43-设计到DSL的转换方法论.md)、[01-44](../../topics/01-基础概念与对比分析/01-44-DSL表达力边界与等价转换策略.md)、[02-56](../../topics/02-场景驱动架构设计/02-56-Spec-Driven%20Development全面体系.md)、[02-57](../../topics/02-场景驱动架构设计/02-57-IT通用场景事件契约模式库.md)
- 外部：[AsyncAPI Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)、[AsyncAPI Bindings 仓库](https://github.com/asyncapi/bindings)、[AsyncAPI GitHub](https://github.com/asyncapi)

---

**最后更新**: 2026-11-18
