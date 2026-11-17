# 2.56 Spec-Driven 契约驱动开发体系

> **置信口径**: 协议/规范语义=【定理】（官方规范保证）；工具能力、架构对比与工程推理=【论证】；正文未单独标注的具体数字（阈值/百分比/时长）按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **本文档定位**：设计原理与选型论证（为什么、选哪种方案）。落地操作步骤与检查清单见 03 系列，尤其 [03-59 消息测试实践指南](../03-架构与运维实践/03-59-消息测试实践指南.md)。
> **时效声明**: 本文事实基于 AsyncAPI Initiative、Microcks、Pact、Spectral 官方发布信息，核实至 2026-11。关键版本：AsyncAPI 3.1.0（2026-01-31 发布）、Microcks 2026-05 进入 CNCF Incubating。

## 目录

- [2.56 Spec-Driven 契约驱动开发体系](#256-spec-driven-契约驱动开发体系)
  - [目录](#目录)
  - [2.56.1 契约驱动开发的核心问题](#2561-契约驱动开发的核心问题)
  - [2.56.2 契约三范式：spec-first / code-first / round-trip](#2562-契约三范式spec-first--code-first--round-trip)
  - [2.56.3 契约评审门禁](#2563-契约评审门禁)
    - [Spectral 规则集定制](#spectral-规则集定制)
    - [breaking change 检测政策](#breaking-change-检测政策)
    - [事件语义化版本](#事件语义化版本)
  - [2.56.4 契约漂移检测](#2564-契约漂移检测)
    - [检测手段](#检测手段)
    - [治理分级](#治理分级)
  - [2.56.5 契约生命周期状态机](#2565-契约生命周期状态机)
  - [2.56.6 契约测试金字塔](#2566-契约测试金字塔)
    - [Microcks 与 Pact 的选型](#microcks-与-pact-的选型)
  - [2.56.7 落地检查清单](#2567-落地检查清单)
    - [PR 阶段（每次契约变更）](#pr-阶段每次契约变更)
    - [CI 阶段（每次代码合并）](#ci-阶段每次代码合并)
    - [运行时/月度治理](#运行时月度治理)
  - [互链与参考来源](#互链与参考来源)
    - [参考来源](#参考来源)

---

## 2.56.1 契约驱动开发的核心问题

Spec-Driven Development（SDD）把事件契约从"事后文档"提升为"协作事实来源"。在消息队列场景下，它的核心目标不是"写一份好看的 AsyncAPI"，而是解决三类工程问题：

1. **协作界面**：生产者与多个消费者在开发前就对消息格式、通道、语义达成一致，降低联调成本【论证】。
2. **变更控制**：通过机器可读的 spec 检测向后兼容性与破坏性变更，把"上线后才发现消费端崩溃"变成"PR 阶段就拦截"。
3. **实现一致性**：让契约与代码双向校验，防止"文档是 3.0、代码还是 2.1"的漂移。

与 02-48 设计工作流的关系：02-48 给出 design-first 六步流程；本文进一步把"spec-first/code-first/round-trip"作为方法论选项，并给出评审、漂移、生命周期、测试分层的系统治理框架。

---

## 2.56.2 契约三范式：spec-first / code-first / round-trip

| 维度 | spec-first（契约先行） | code-first（实现先行逆向生成） | round-trip（双向同步） |
| ---- | ---------------------- | ------------------------------ | ---------------------- |
| 起点 | 先写/改 AsyncAPI，再生成代码与测试 | 先写注解/模型，再用 Springwolf/FastStream 等工具导出 spec | 同时维护 spec 与代码，CI 双向 diff |
| 适用条件 | 跨团队消费 ≥3 个、新服务、对外事件 API | 内部原型、单团队、遗留系统比例高 | 平台组有能力维护工具链、核心链路已稳定 |
| 一致性保证 | 高（代码从 spec 生成） | 中（依赖生成器与手工发布） | 高（双向校验，任何一侧变更都被发现） |
| 主要成本 | 学习曲线、评审流程、初始设计时间 | 生成器支持有限、spec 视角弱、漂移风险 | 工具链复杂、需要两侧变更流程 |
| 典型风险 | 设计脱离实现细节、生成代码不符合团队习惯 | 消费者无法提前看到契约、字段语义缺失 | 两侧冲突时决策链长、工具误报 |
| 推荐遗留比例 | 新系统/重构优先 | 遗留 >60% 且短期无法迁移时过渡 | 遗留 20%-60% 的渐进改造阶段 |

选型建议【论证】：

- **对外事件 API**（被外部团队/组织消费）一律 spec-first；消费者需要提前评审与 mock。
- **纯内部快速迭代**可 code-first，但必须把生成的 spec 提交到契约仓库，并接受 CI 门禁。
- **平台成熟期**采用 round-trip：生产代码与契约仓库各有 owner，任何一侧变更触发 diff 告警，由契约 owner 裁定。

---

## 2.56.3 契约评审门禁

契约评审不是"人工看一遍"，而是可自动化的三层门禁：语法校验、风格规则、破坏性变更检测。

### Spectral 规则集定制

【论证】Spectral 内置 `spectral:asyncapi` 规则集，并支持自定义规则。组织应把命名规范、必填字段、binding 版本声明等治理要求写成 error 级规则，直接阻断 PR。

```yaml
# .spectral.yaml
extends: ["spectral:asyncapi"]
rules:
  asyncapi-document-version: error
  asyncapi-info-contact: warn
  asyncapi-operation-operationId: error
  asyncapi-channel-no-query-version: warn

  # 自定义：每个 message 必须声明 payload schema
  message-payload-required:
    description: Every message must declare a payload schema
    given: "$.components.messages.*"
    then:
      field: payload
      function: defined
    severity: error

  # 自定义：每个 binding 必须声明 bindingVersion
  binding-version-required:
    description: All protocol bindings must declare bindingVersion
    given: "$..bindings.*"
    then:
      field: bindingVersion
      function: defined
    severity: error

  # 自定义：header 必须包含 trace-id 与 idempotency-key
  message-trace-idempotency-headers:
    description: Message headers must include trace-id and idempotency-key
    given: "$.components.messages.*.headers.properties"
    then:
      function: schema
      functionOptions:
        schema:
          required: [trace-id, idempotency-key]
    severity: error
```

### breaking change 检测政策

【论证】AsyncAPI CLI 提供 `asyncapi diff` 命令，可比较两个 spec 的差异并标注变更类型。组织应把该命令嵌入 CI，并按语义化版本政策处理：

| 变更类型 | minor 允许 | patch 允许 | major 必须 |
| -------- | ---------- | ---------- | ---------- |
| 加可选字段 / 加 channel / 加示例 | ✓ | ✓ | — |
| 改必填为可选、改字段描述、补 binding 版本 | — | ✓ | — |
| 删字段、改必填、改类型、删 channel/message | — | — | 必须技术评审 + 消费方影响评审 |
| 改 channel address / 改 message 名 | — | — | 视为新契约，旧契约走退役流程 |

审批规则【估算】：

- **patch/minor**：自动化合并，通知订阅该事件的消费方。
- **major**：必须提交《迁移方案》与《消费方影响清单》，由契约 owner 与至少一名消费方代表共同批准。

### 事件语义化版本

- **spec 级版本**：AsyncAPI 文档 `info.version`，反映契约文档整体演进。
- **message 级版本**：建议把版本号放入 channel address（如 `orders.created.v1`）或 message name（如 `OrderCreatedV1`）。
- 两者关系：message 级 major 升级通常触发 spec 级 major 升级，但 spec 级 minor 不一定影响消息运行时兼容性。

---

## 2.56.4 契约漂移检测

漂移（drift）指实现与契约不再一致。消息系统中常见来源：

1. **手工绕过生成器**：开发者直接改 model 代码，未回写 spec。
2. **框架默认值**：Spring Cloud Stream / FastStream 的默认序列化、header 注入与契约声明不同。
3. **schema 注册表与契约不同步**：Registry 中的 Avro/JSON Schema 由另一份脚本注册，未与 AsyncAPI 对齐。
4. **多语言消费端**：Python 消费者自行反序列化，未使用生成的 model。

### 检测手段

| 层级 | 手段 | 触发时机 | 工具示例 |
| ---- | ---- | -------- | -------- |
| CI 静态对比 | 生成代码/文档与契约 diff | 每次 PR | `asyncapi diff`、Modelina 生成后 `git diff --exit-code` |
| 运行时探针 | 抓取生产消息并校验 schema | 定时或持续 | Microcks 一致性测试、自定义 schema validator |
| 注册表对账 | 比较 Registry schema 与契约 schema | 每日 | CI 脚本对比 Avro JSON 与 AsyncAPI payload |
| 消费端反馈 | 收集消费端反序列化失败事件 | 运行时 | 可观测平台告警 + 事件 schema 版本标签 |

### 治理分级

| 漂移级别 | 判定标准 | 处理动作 |
| -------- | -------- | -------- |
| P0 阻断 | 破坏向后兼容且已影响消费端 | 回滚生产者发布，强制修复契约或代码 |
| P1 告警 | 非破坏不一致（如描述/示例缺失） | 72 小时内补齐，否则阻断下一次发布 |
| P2 提示 | 仅注释/元数据差异 | 下次改契约时一并更新 |

---

## 2.56.5 契约生命周期状态机

事件契约应像 API 一样有明确生命周期：draft → active → deprecated → retired。

| 状态 | 定义 | 转换条件 | SLA / 治理动作 |
| ---- | ---- | -------- | -------------- |
| **draft** | 设计中的契约，尚未被任何服务实现 | 事件风暴/需求评审后创建 | 可随意修改，不保证兼容性；需在事件目录标为 draft |
| **active** | 已有生产消费者，变更需走门禁 | 至少一个生产 consumer 接入 | 任何变更必须 CI 通过；minor/patch 自动，major 需审批 |
| **deprecated** | 不再推荐新消费方接入 | major 升级后旧版本进入 | 公告期 ≥30 天【估算】；事件目录显示迁移目标 |
| **retired** | 已下线，无活跃 consumer | 公告期结束且监控确认无消费 | 从注册表删除 schema；保留 spec 历史版本供审计 |

状态转换图（Mermaid 简化）：

```text
draft --(PR 评审通过)--> active
active --(major 升级)--> deprecated
deprecated --(公告期结束 + 无消费)--> retired
```

在事件目录中的可视化：把 `info.x-lifecycle.status` 或 02-54 契约骨架的 `metadata.status` 字段同步到目录平台（如 EventCatalog、Backstage），用颜色标签区分四态。消费者在选择事件时首先看到 active，其次是带公告期的 deprecated；retired 不再出现在发现目录，但保留在历史版本查询页。

---

## 2.56.6 契约测试金字塔

事件系统的契约测试应分层投入，避免把大量成本压在端到端场景。

| 层级 | 测试内容 | 工具示例 | 投入建议 | 与 03-59 的衔接 |
| ---- | -------- | -------- | -------- | ---------------- |
| **unit（schema 校验）** | 单个 payload/headers 是否符合 JSON Schema | `asyncapi validate`、Ajv、pytest-jsonschema | 每 message 至少 1 组正向 + 2 组边界/异常用例 | 03-59 单元测试策略 |
| **contract（provider-consumer 契约测试）** | 生产者消息是否满足消费者期望；消费者能否正确反序列化 | Microcks、Pact MessagePact | 跨团队/核心链路优先；每条 active 契约至少 1 组 | 03-59 集成测试策略 |
| **e2e（场景测试）** | 端到端业务场景：发送→路由→消费→补偿 | 自定义测试框架 + Testcontainers | 仅覆盖关键业务路径，占比最低 | 03-59 可靠性/混沌测试 |

### Microcks 与 Pact 的选型

【论证】Microcks 2026-05 晋升为 CNCF Incubating 项目，支持从 AsyncAPI 生成 mock 与一致性测试，适合"spec-first + 多协议"的组织：把 AsyncAPI 中的 examples 发布到 Kafka/MQTT/AMQP broker，再验证真实消费者收到的消息是否匹配契约。

Pact 的 `MessagePact` 模式适合消费者驱动的契约：消费者定义期望的消息格式，Pact 验证生产者是否满足。它本身不直接解析 AsyncAPI，但社区已有 `pact-asyncapi-comparator` 等工具做子集比对。

投入配比【估算】：unit 50%、contract 40%、e2e 10%。跨团队链路越多，contract 层投入越高。

---

## 2.56.7 落地检查清单

### PR 阶段（每次契约变更）

- [ ] `asyncapi validate asyncapi.yaml` 通过（含 examples）。
- [ ] `spectral lint asyncapi.yaml --ruleset .spectral.yaml --fail-severity=warn` 0 error。
- [ ] 对 active 契约运行 `asyncapi diff <base> <head>`，破坏性变更已标注。
- [ ] major 变更附《消费方影响清单》与《迁移方案》。
- [ ] 新增/修改 message 已更新契约骨架的 `metadata.status` 与 `reviewers`。

### CI 阶段（每次代码合并）

- [ ] 生成代码/文档与契约对比：`git diff --exit-code generated/` 或 Modelina 输出无差异。
- [ ] contract 测试通过：Microcks 一致性测试或 Pact provider verification。
- [ ] schema registry 对账脚本通过（对比 AsyncAPI payload 与注册表 schema）。

### 运行时/月度治理

- [ ] 事件目录中所有 active/deprecated 契约状态正确、owner 信息完整。
- [ ] deprecated 契约公告期 ≥30 天，且目录展示迁移目标。
- [ ] 每月抽样运行 Microcks 运行时一致性测试，覆盖 ≥80% active 契约【估算】。
- [ ] 消费端反序列化失败事件按 schema 版本归因，形成漂移告警闭环。

快速命令集：

```bash
# 校验 + lint（本地/CI）
asyncapi validate asyncapi.yaml
spectral lint asyncapi.yaml --ruleset .spectral.yaml --fail-severity=warn

# 与上一个 tag 的破坏性变更扫描
asyncapi diff asyncapi.yaml origin/main:asyncapi.yaml

# 批量校验契约仓库
for f in contracts/asyncapi/*/*.yaml; do
  asyncapi validate "$f" || echo "FAIL $f"
done
spectral lint "contracts/asyncapi/**/*.yaml" --ruleset .spectral.yaml
```

---

## 互链与参考来源

- 想了解 AsyncAPI 组织级治理、事件目录、bindings 工程细节与 CI 门禁，参见 [1.37 AsyncAPI 组织级应用与治理](../01-基础概念与对比分析/01-37-AsyncAPI组织级应用与治理.md)。
- 想了解 design-first 六步工作流与版本治理，参见 [2.48 契约设计工作流与事件 API 治理](02-48-契约设计工作流与事件API治理.md)。
- 想了解契约骨架、命名规范、版本化与弃用模板，参见 [2.54 事件契约模板库与命名规范](02-54-事件契约模板库与命名规范.md)。
- 想了解 DSL 能表达什么、不能表达什么，以及不能表达时的等价工程手段，参见 [1.44 DSL 表达力边界与等价转换策略](../01-基础概念与对比分析/01-44-DSL表达力边界与等价转换策略.md)。
- 想了解消息测试落地操作、环境搭建、验收标准与检查清单，参见 [03-59 消息测试实践指南](../03-架构与运维实践/03-59-消息测试实践指南.md)。

### 参考来源

- [AsyncAPI Specification 3.1.0](https://www.asyncapi.com/docs/reference/specification/v3.1.0)
- [AsyncAPI 3.1.0 Release Notes (2026-01-31)](https://www.asyncapi.com/blog/release-notes-3.1.0)
- [AsyncAPI CLI Documentation](https://www.asyncapi.com/docs/tools/cli)
- [Spectral AsyncAPI Rules](https://docs.stoplight.io/docs/spectral/1e63ffd0220f3-async-api-rules)
- [Microcks AsyncAPI Conventions](https://microcks.io/documentation/references/artifacts/asyncapi-conventions/)
- [CNCF: Microcks Becomes CNCF Incubating Project (2026-05-07)](https://www.cncf.io/blog/2026/05/07/microcks-becomes-a-cncf-incubating-project/)
- [Pact Message Pact Documentation](https://docs.pact.io/implementation_guides/pact_plugins/advanced_usage/messages)
- [Pact AsyncAPI Comparator](https://github.com/YOU54F/pact-asyncapi-comparator)

---

**最后更新**: 2026-11-18
