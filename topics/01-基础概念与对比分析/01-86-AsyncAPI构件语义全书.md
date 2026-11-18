# 01-86 AsyncAPI 构件语义全书

> **置信口径**: 构件语义=【定理】（以 [AsyncAPI 3.0 官方规范](https://www.asyncapi.com/docs/reference/specification/v3.0.0) 为唯一权威）；语义争议与陷阱=【论证】。
> **时效声明**: 核实至 2026-11（AsyncAPI 3.0.0；bindings 版本见 bindings-matrix）。
> **本文档定位**: 地基旗舰（批次 112c）。每个构件的"设计意图+完整语义+边界案例"——01-32 论工具生态，本书论语言本身；字段级绑定细节归 bindings-matrix，不复述。

## 目录

- [1.86.1 info 与 servers](#1861-info-与-servers)
- [1.86.2 channels：地址与参数](#1862-channels地址与参数)
- [1.86.3 operations：action/reply/traits 的精确语义](#1863-operationsactionreplytraits-的精确语义)
- [1.86.4 messages：payload/headers/correlationId 的分界](#1864-messagespayloadheaderscorrelationid-的分界)
- [1.86.5 components 与引用规则](#1865-components-与引用规则)
- [1.86.6 语义陷阱集（8 个）](#1866-语义陷阱集8-个)
- [1.86.7 参考来源](#1867-参考来源)

---

## 1.86.1 info 与 servers

- `info`：标识元数据；`version` 是**文档版本非 API 版本**——语义版本应表达契约兼容性（2-60 演化策略的挂载点）。
- `servers`：`host`+`protocol`+`protocolVersion` 三元组【定理】。`protocolVersion` 常缺省—— broker 特性判断应显式声明（如 kafka 协议版本决定 KIP-896 兼容性，01-75 已证其生产影响）。
- 设计意图【论证】：servers 是部署拓扑声明——同一 spec 可声明多环境 server，通道绑定到 server 即环境路由。

## 1.86.2 channels：地址与参数

- `address` 是目标标识（Kafka topic/NATS subject/AMQP routing key）【定理】；与 `name`（文档标签）分离是 3.0 的澄清——2.x 的"channel name 即地址"多义性被终结。
- `parameters`：地址模板变量（`{siteId}`）的声明【定理】；**绑定发生在解析后**——参数未替换的地址不是合法目标。
- 边界案例【论证】：MQTT 多层通配符主题（`sensors/+/temp`）作为 address 合法，但 parameters 无法覆盖 `+` 的匹配语义——通配符订阅的 address 应视为模式而非实例。

## 1.86.3 operations：action/reply/traits 的精确语义

- `action: send | receive` 的参照系【定理】：**以应用程序为参照**——send=应用发送，receive=应用接收。与 2.x subscribe/publish 的"以 broker 为参照"正好相反——迁移时的方向反转错误是最高频事故。
- `reply` 对象：请求响应模式的规范表达——`address`（去哪收）+`channel`（消息形态）【定理】。MQTT5 Response Topic/Correlation Data 的原语级落地（01-64）。
- `traits`：operation/message 的可复用横切组合【定理】；组合语义=浅合并——同名键覆盖，无继承链。多层 traits 的展开顺序由规范固定（先列先生效）。

## 1.86.4 messages：payload/headers/correlationId 的分界

- `payload`：业务载荷（schema 引用）【定理】。
- `headers`：协议级头部信封【定理】。**分界争议**【论证】：trace-id 属 headers（基础设施关注）还是 payload 字段（业务可见）？本项目约定：trace-id/idempotency-key 归 headers——消费者业务代码不应解析基础设施关注。
- `correlationId`：关联提取表达式【定理】——声明"从消息的哪个位置取关联键"，是声明式关联而非值。
- `contentType`：payload 的媒体类型；与 headers.content-type 的冲突由消息级为准【论证】。

## 1.86.5 components 与引用规则

- components 是可复用构件的命名空间【定理】；`$ref: '#/components/messages/X'` 内部引用。
- 外部 `$ref`（`./contract.yaml#/messages/X`）【定理】：URI 解析语义明确，但**工具支持参差**——本项目 contract-spec-check 不解析外部引用（批次 107 P1 已登记），消费方（代码生成器）多忽略——工程现实是"外部 $ref 是规范语义、生态半成品"。

## 1.86.6 语义陷阱集（8 个）

| # | 陷阱 | 正确理解 |
| ---- | ---- | ---- |
| 1 | action 方向参照系混淆 | 以应用为参照（send=应用发出） |
| 2 | operation 与 channel 一对一绑定遗漏 | 一个 channel 可有 send/receive 两 operation |
| 3 | channel 与 topic 多义映射 | 3.0 address 已分离 name 与地址 |
| 4 | parameters 未替换即投递 | 参数绑定是地址解析的前置 |
| 5 | oneOf 消息无判别器 | 需 discriminator 或 content-based 路由约定 |
| 6 | headers/payload 分界随意 | 基础设施关注归 headers 是工程约定 |
| 7 | traits 期待继承语义 | 浅合并覆盖，无多态 |
| 8 | bindingVersion 缺省依赖"latest" | 显式声明版本（批次 107 P1：13 处待补） |

## 1.86.7 参考来源

- 项目内：[01-32](01-32-AsyncAPI工程生态深度分析.md)、[bindings-matrix](../../Testing/06-契约语义测试/01-契约规格/bindings-matrix.md)、[01-64](01-64-MQTT-5.0协议全解析.md)、[DSL_ASYNCAPI_AUDIT](../DSL_ASYNCAPI_AUDIT.md)
- 外部：[AsyncAPI 3.0.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)、[AsyncAPI GitHub](https://github.com/asyncapi/spec)

---

**最后更新**: 2026-11-18
