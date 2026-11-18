# 契约设计规范 v1（Contract Design Specification）

> **地位**：组织级契约工程统领规范。合并 topics/02-54（模板库）、02-56（Spec-Driven）、02-60（演化策略）的规范条款于一处；三篇保持论证深度，本文管"规矩合卷"。修订走治理变更批（K5）。
> **适用**：本项目全部契约资产（contract.yaml/AsyncAPI spec/ODCS 导出）+ 消费这些资产的 agent/工具。
> **生效**: 2026-11-18（批次 157 首版）。

## 一、命名规范

1. 场景契约：`{域}.{资源}` 小写点分（如 `orders.events`）；DLQ 通道=主通道+`.dlq` 后缀；
2. 消息类型：PascalCase 领域事件名（`OrderCreatedEvent`）；命令动词开头（`ReserveStockCmd`）；
3. 字段：camelCase；保留字禁用（`type`/`source` 留给信封）；时间字段统一后缀 `At`（occurredAt）；
4. spec 文件名：`asyncapi-<系统>-example.yaml`；**AsyncAPI 版本声明：新文档默认 `3.1.0`**（2026-01-31 minor 零破坏，评估见 DSL_ASYNCAPI_AUDIT 附录；存量 3.0.0 不强制改）；场景包：`NN-<场景名>/` 两位序号。

## 二、信封与载荷

1. 信封/载荷分离（01-84 模式 1）：基础设施关注归 headers（trace-id/idempotency-key），业务归 payload；
2. 信封四必填：`messageId/schemaVersion/occurredAt/type`；schemaVersion 语义化（`MAJOR.MINOR`）；
3. payload 必填 ≤3（02-60 基线）；幂等键随 headers 全链传播（01-77 crosslang 安全级标注）。

## 三、版本与演化

1. 兼容矩阵与六种变更分类执行 02-60 §2.2（原文引用不复制）；
2. 红线四类触发 MAJOR+评审（语义变更/删枚举/键结构/envelope 结构）；
3. 演化门禁链：asyncapi diff→Registry 兼容检查→tc-assert→drift 通知（02-60 §2.4 链）。

## 四、lint 分级门禁

| 级 | 规则例 | 处置 |
| ---- | -------- | ------ |
| ERROR | spec 可解析/必填构件/binding 字段合法（contract-spec/binding-check 现集） | 阻断提交（E0） |
| WARN | bindingVersion 显式/x-semantics 值∈十二维度/目录与章节一致 | 挂账修复（warn-ledger） |
| INFO | 建议性（命名前缀统一/描述完整度） | 报告不阻断 |

门禁集成：E0 现有第 6/7 步=ERROR 级；WARN 级入 warn-ledger.tsv 季度清零；INFO 级随语义抽检。

## 五、领域模板缺口清单（挂账）

| 域 | 现状 | 缺口 |
| ---- | ------ | ------ |
| IT 通用 | 02-57 六模式+三模板 | 无 |
| 金融 | 01-45 标准纵览 | 缺 ISO 20022 子集契约模板（pacs/pain 映射） |
| IoT | 01-46+05-iot-telemetry 包 | 缺 Sparkplug 命名空间模板 |
| 电商 | 01-46+01-order 包 | 缺订单状态机通用模板（现有为单场景实例） |
| 医疗/物流/能源 | 01-45 纵览 | 全缺（FHIR/EPCIS/OpenADR 模板）——按域需求优先级排期 |

## 六、工具链与本文的接口

- 校验执行：contract-spec-check（ERROR）/contract-binding-check（ERROR）/tc-assert-check（WARN 族）/contract-to-odcs（导出）；
- 规则机读：conversion-rules.tsv（01-88）/dsl-schema.json（结构）/evidence-index.tsv（实证回链）；
- 设计论证：01-89 五步链（评审必走）；本文 §一~§三 是 01-89 的输入约束。

---

**最后更新**: 2026-11-18
