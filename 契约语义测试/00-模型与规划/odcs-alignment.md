# ODCS v3.1.0 对齐映射（契约语义测试 ↔ 国际数据契约标准）

> **置信口径**: ODCS 结构=【定理】（以 [bitol 官方 v3.1.0](https://bitol.io/bitol-announces-odcs-v3-1-0-stronger-smarter-and-stricter/) 为准，2025-12 发布）；映射设计=【论证】。
> **时效声明**: 核实至 2026-11。国际格局：ODCS v3.1.0 已为 Linux Foundation AI & Data（Bitol）旗下单一收敛标准，竞对 DCS 已弃用归并（DataKitchen 2026-10 格局综述佐证）。
> **本文档定位**: 批次 79。定义本项目场景 DSL（contract.yaml）与 ODCS 的字段级映射，补 quality/SLA 维度，使 L5 契约包具备国际互操作出口。

## 一、为什么对齐 ODCS

1. **标准收敛已成事实**：2026 年数据契约工具生态（DataKitchen 2026-10 评测：5 开源+4 商业工具）以"ODCS 文件可导入导出"为第一筛选条件——不对齐即被国际工具链排除。
2. **维度补全**：本项目 contract.yaml 强于消息语义（x-semantics/状态机/invariants），弱于数据契约 governance 面（质量规则/SLA/角色责任）——ODCS 的 schema/quality/sla/roles/servers 五块恰好补齐。
3. **双向而非替换**：消息级语义（QoS/背压/死信）是 ODCS 不覆盖的领域，保持本项目 DSL 为主、ODCS 为治理导出层。

## 二、字段映射表（contract.yaml → ODCS v3.1.0）

| ODCS 块 | ODCS 字段 | 本项目来源 | 对齐方式 |
| ---- | ---- | ---- | ---- |
| apiVersion+kind | odcs v3.1.0 / DataContract | 场景包版本头 | 导出时生成 |
| id | <域>.<场景> | contract.yaml: scenario | 直译（如 retail.order-lifecycle） |
| info | name/owner/version/status | scenario/version + 责任角色【论证】 | 直译+默认 |
| schema | properties[].name/type/format/quality | contract.yaml: messages[].fields | 直译；desc→description；enum 保留 |
| quality | type/severity/mustBeNull/acceptedValues | **新增**（见 §三） | 场景包新段 |
| sla | freshness/availability/retention | **新增**（见 §三） | 场景包新段；与消息 TTL 语义区分【论证】 |
| roles | producer/consumers/steward | 场景主系统+消费方文档 | 导出时从 SEMANTICS.md 互链推断 |
| servers | 物理落地 | asyncapi.yaml: servers | 直译（kafka:9092 等） |
| customProperties | x-semantics/invariants/stateMachine | 本项目特有 | 原样入 customProperties（ODCS 扩展机制） |

## 三、场景包新增两段（以 01-order-lifecycle 为范例，其余 7 场景按同模式补）

contract.yaml 增：

```yaml
quality:                       # ODCS quality 块：数据质量断言
  - column: OrderCreatedEvent.orderId
    type: not_null
    severity: error            # 违反=契约破坏，禁止发布
  - column: OrderCreatedEvent.occurredAt
    type: freshness            # 事件时效（区别于消息 TTL：这是业务时效）
    maximum: PT5M
sla:                           # ODCS sla 块：服务级承诺
  freshness: PT1M              # 端到端延迟承诺（消费可见）
  availability: 99.95%         # 【估算】默认值，按部署调整
  retention: P30D              # 与 broker retention 对账（审计场景 07 为 P7Y 级）
```

**消息语义 vs 数据 SLA 的边界**【论证】：TTL过期（TEST-14 维度）是 broker 消息属性；freshness/availability 是管道级承诺——同一事件两者并存（broker 不丢且管道及时）。

## 四、导出与校验工具链（落地项）

1. `contract-to-odcs.py`（topics/scripts/，批次 79 交付）：contract.yaml → ODCS YAML 导出器（python3+PyYAML 无第三方依赖），含 §二映射规则；`--check` 模式反向校验场景包含必备段。
2. E0 扩展评估：导出器自检入 E0 第 8 步（待四件套批次统一扩展，本批先交付工具+范例）。
3. ODCS 官方 JSON Schema 校验（bitol 仓库）为外部校验器，挂接时机=真实导出演练（用户在场批次）。

## 五、与 01-55/02-56 的关系

01-55（数据契约与数据产品化）是知识篇、02-56 是 Spec-Driven 体系——本对齐是其**执行层**：知识层回答"数据契约是什么"，本文件给出"我们的契约如何变成国际标准的契约"。冲突时以 ODCS 官方规范为准。

---

**最后更新**: 2026-11-18
