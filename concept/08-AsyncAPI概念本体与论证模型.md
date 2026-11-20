# 08 AsyncAPI 概念本体与论证模型

> **定位**：在 [06 概念关系理论](./06-概念关系理论.md) 的七型框架与 [05 论证方法分类学](./05-论证方法分类学.md) 的论证型谱下，为 [01-86 AsyncAPI 构件语义全书](../topics/01-基础概念与对比分析/01-86-AsyncAPI构件语义全书.md) 建立本体地位与可验证论证链。
> **置信口径**：构件定义=【定理】（以 AsyncAPI 3.0.0 官方规范为源；2026-11-21 仓基线升 3.1.0 后零破坏兼容、构件定义不变）；关系判定与表达力命题=【论证】；工程覆盖缺口=【估算】。

## 目录

- [08 AsyncAPI 概念本体与论证模型](#08-asyncapi-概念本体与论证模型)
  - [目录](#目录)
  - [8.1 构件本体论：11 个 AsyncAPI 3.x 构件的存在论地位](#81-构件本体论11-个-asyncapi-3x-构件的存在论地位)
    - [8.1.1 info](#811-info)
    - [8.1.2 servers](#812-servers)
    - [8.1.3 channels](#813-channels)
    - [8.1.4 parameters](#814-parameters)
    - [8.1.5 operations（含 action / reply / traits）](#815-operations含-action--reply--traits)
    - [8.1.6 messages](#816-messages)
    - [8.1.7 payload](#817-payload)
    - [8.1.8 headers](#818-headers)
    - [8.1.9 correlationId](#819-correlationid)
    - [8.1.10 components](#8110-components)
    - [8.1.11 traits](#8111-traits)
  - [8.2 构件间关系七型映射表](#82-构件间关系七型映射表)
    - [8.2.1 关系型分布统计与边界判定](#821-关系型分布统计与边界判定)
  - [8.3 四层验证论证链](#83-四层验证论证链)
    - [8.3.1 实例：MQTT qos 绑定的四层论证](#831-实例mqtt-qos-绑定的四层论证)
    - [8.3.2 层间失效传导示例](#832-层间失效传导示例)
  - [8.4 表达力定理集](#84-表达力定理集)
    - [8.4.1 定理置信上限与可证伪条件](#841-定理置信上限与可证伪条件)
  - [8.5 参考来源](#85-参考来源)

---

## 8.1 构件本体论：11 个 AsyncAPI 3.x 构件的存在论地位

本节把官方规范中的 11 个核心构件（info、servers、channels、parameters、operations、messages、payload、headers、correlationId、components、traits）放到**实体 / 关系 / 属性**三元范畴中，并给出身份条件与生命周期。
action 与 reply 是 `operations` 对象内部的取值/子对象，不单独成节点，但在 operations 条目中讨论。

| 构件 | 存在论范畴 | 身份条件 | 生命周期 |
| ---- | ---------- | -------- | -------- |
| info | **实体**（元数据单体） | `title`+`version` 二元组在同一文档内唯一标识该契约描述；`version` 是文档版本而非 API 运行时版本 | 随文档发布创建；语义版本变更触发治理层 diff |
| servers | **实体**（部署端点集合） | `host`+`protocol`+`protocolVersion` 三元组唯一确定一个 server；同一 spec 内 `serverId` 唯一 | 在环境切换/协议升级时增删；runtime 切换不修改 spec |
| channels | **实体**（抽象地址） | `name`（文档标签）与 `address`（运行时目标）分离；3.0 后同一 channel 以 `address` 为运行时身份 | 随主题/队列生命周期创建；删除 channel 仅移除描述不删除 broker 实体 |
| parameters | **属性**（地址模板变量） | 由 `name`+`location`（$message.header#/... 或 $message.payload#/...）确定；替换后地址才合法 | 绑定发生在地址解析阶段；值由运行时上下文注入 |
| operations | **实体**（应用动作） | `title` 或文档内 operationId 唯一；`action: send \| receive` 决定方向；一个 channel 可挂 send/receive 两个 operation | 创建/删除/重命名 operation 不影响 channel 存在 |
| messages | **实体**（传输数据单元） | `name` 在 components/messages 或 channel.messages 内唯一；同一 message 可被多个 operation 引用 | 与 schema 版本绑定；payload 结构变更产生新 message 身份 |
| payload | **属性**（业务载荷结构） | 由 schema 引用或内联 schema 确定；同一 payload 可在多 message 中复用 | 随 schema 版本演化；变更通常产生新 message |
| headers | **属性**（协议级信封） | 键值型 schema；与 payload 共享 message 但命名空间隔离 | 基础设施关注（trace-id、idempotency-key）通常独立演化 |
| correlationId | **属性**（关联提取表达式） | 由 `location` 表达式确定；不是值本身，而是“从哪取值”的声明 | 与请求响应模式共生；模式变化则表达式失效 |
| components | **实体**（可复用命名空间） | 是 `$ref` 解析的根容器；messages/schemas/operations/parameters 等子命名空间独立 | spec 初始化时创建；随可复用构件增加而扩展 |
| traits | **关系/模板**（横切组合） | 由 `title`+浅合并规则确定；多层 traits 展开顺序由规范固定 | 应用时展开为 operation/message 的实例属性；trait 自身不运行时 |

以下 YAML 片段展示 11 个构件在 AsyncAPI 3.x 文档中的典型位置：

```yaml
asyncapi: '3.1.0'
info:                          # 构件 1：info
  title: Order API
  version: '1.2.0'
servers:                       # 构件 2：servers
  prod:
    host: kafka.example.com:9092
    protocol: kafka
    protocolVersion: '3.7'
channels:                      # 构件 3：channels
  orders:
    address: orders.{region}
    parameters:                # 构件 4：parameters
      region:
        location: '$message.header#/region'
operations:                    # 构件 5：operations
  sendOrder:
    action: send
    channel:
      $ref: '#/channels/orders'
    messages:
      - $ref: '#/components/messages/OrderCreated'
components:                    # 构件 10：components
  messages:                    # 构件 6：messages
    OrderCreated:
      headers:                 # 构件 8：headers
        type: object
        properties:
          trace-id:
            type: string
      payload:                 # 构件 7：payload
        $ref: '#/components/schemas/Order'
      correlationId:           # 构件 9：correlationId
        location: '$message.header#/correlation-id'
  schemas:
    Order:
      type: object
      properties:
        orderId:
          type: string
  operationTraits:             # 构件 11：traits
    kafkaDefaults:
      bindings:
        kafka:
          clientId: order-service
```

### 8.1.1 info

`info` 是契约文档的元数据实体，不是运行时 API 的身份。
其 `version` 字段常被误用为 API 版本——规范明确它是**文档版本**【定理】。
在治理层，info.version 的语义版本化是 diff 与兼容判定的锚点。

身份条件的核心在于：
info 的唯一性由 `title` 与 `version` 共同承担。
同一项目不同环境（dev/prod）可共享同一个 info.version，只要 title 相同即视为同一契约描述；
若 version 变更而 title 不变，则触发变更通知。
生命周期上，info 在 spec 创建时诞生，在每次发布事件（PR merge、tag）中可能更新，但 runtime 的 broker 实例不会感知 info 的变化。

### 8.1.2 servers

`servers` 是部署拓扑声明。
`protocolVersion` 缺省会导致 broker 特性判断歧义，例如 Kafka 协议版本决定 KIP-896 兼容性。
身份条件强调：同一 `host` 不同 `protocolVersion` 应视为不同 server。

servers 的生命周期与运行时环境强相关：开发、测试、生产环境通常对应不同的 server 条目。同一 spec 可声明多个 server，channel 通过 `servers` 字段选择可部署的 server 子集。删除 server 条目仅影响文档描述，不会停止运行中的 broker；但错误的 protocolVersion 声明会导致代码生成器产生不兼容的客户端。

### 8.1.3 channels

`channels` 是消息传输的抽象地址实体。3.0 的关键澄清是 `name` 与 `address` 分离：name 是文档标签，address 是 Kafka topic、NATS subject、AMQP routing key 等运行时目标【定理】。MQTT 多层通配符主题（`sensors/+/temp`）作为 address 合法，但应视为模式而非实例。

channel 的生命周期通常由基础设施团队管理：创建、扩分区、删除对应于 broker 端的 topic/queue 操作。在 AsyncAPI 文档中删除 channel 仅是描述层动作，不会级联删除运行时资源。身份条件上，同一 spec 内 channel 的 `name` 必须唯一，而 `address` 可跨 spec 重复——这正是多环境复用同一 spec 的基础。

### 8.1.4 parameters

`parameters` 是地址模板的属性集合。其存在论地位是**属性**而非独立实体：参数未替换的 address 不是合法目标。生命周期绑定在地址解析阶段，值来源可以是 message header 或 payload 字段。

parameters 的身份条件由 `name` 与 `location` 共同决定。`location` 指向运行时取值位置，例如 `$message.header#/tenantId` 或 `$message.payload#/orderId`。同一 channel 内 parameter name 必须唯一。反例：若声明 `address: 'orders/{id}'` 却未声明 `id` 参数，则文档语法层面不合法——说明 parameters 是 channel address 的必要组成部分（R2 P），尽管空 channel 可合法存在。

### 8.1.5 operations（含 action / reply / traits）

`operations` 是应用动作实体，核心子结构：

- `action: send | receive`：以应用程序为参照系【定理】；send=应用发出，receive=应用接收。这与 2.x subscribe/publish 的 broker 参照系相反，是迁移事故最高频根因。
- `reply`：请求响应模式的规范表达，含 `address`（去哪收）与 `channel`（消息形态）【定理】。
- `traits`：可复用横切模板，组合语义=浅合并（同名覆盖，无继承链）。

身份条件：同一 channel 下的 send operation 与 receive operation 是两个独立 operation 实例，分别拥有 action 取值。operations 的生命周期与业务功能绑定：新增一个“发送订单事件”的 operation 对应于业务事件发布能力的声明；删除 operation 不影响 channel 与 message 的存在。值得注意的是，action 取值在同一 operation 内具有 R4 M 互斥性：一个 operation 不能同时是 send 与 receive。

### 8.1.6 messages

`messages` 是传输数据单元实体，由 payload、headers、correlationId 三部分属性组成。其身份与 schema 版本强绑定；一个 message 定义可在多处 `$ref` 引用。

message 的生命周期与 schema 版本同步：payload 结构变更通常意味着新的 message 版本（或新的 schema 版本引用）。在 components/messages 中定义的 message 可通过 `$ref` 被多个 operation 引用，这体现了 message 与 operation 之间的 R5 A 关联而非 R2 P 组成。若 message 被删除，所有引用它的 operation 在 L3 构件规则检查中会报错。

### 8.1.7 payload

`payload` 是业务载荷属性，承载 schema 引用或内联 schema。存在论地位：它是 message 的组成部分，不是独立运行时实体。

payload 的身份条件由 schema 决定：同一 schema 可被多个 message 复用；不同 message 引用同一 schema 时，payload 在逻辑上是同一数据契约。生命周期上，schema 的演进（如新增可选字段）可能保持同一 message 身份，而 breaking change（如删除字段、修改类型）通常需要新的 message/schema 版本。payload 不表达兼容性规则——那是治理层 x- 扩展或外部注册中心的职责。

### 8.1.8 headers

`headers` 是协议级信封属性。工程约定：trace-id、idempotency-key 等基础设施关注归 headers，消费者业务代码不应解析它们。headers 与 payload 共享 message 但命名空间隔离。

headers 的身份条件由键值型 schema 决定。其生命周期通常与基础设施关注点同步：新增 trace-id 头不需要变更 payload schema，这正是 headers/payload 分界的工程价值。反例：若把业务订单状态放在 headers，会导致 headers 承载业务语义，破坏分界约定——这是 01-86 列出的第 6 个语义陷阱。

### 8.1.9 correlationId

`correlationId` 是关联提取表达式属性，声明“从消息的哪个位置取关联键”，不是关联值本身。它只在请求响应或因果追踪场景下有意义。

correlationId 的身份条件由 `location` 表达式唯一确定。例如 `$message.header#/correlation-id` 与 `$message.payload#/meta/correlationId` 是两个不同的 correlationId 声明。生命周期与请求响应模式绑定：若业务从请求响应迁移到纯事件驱动，correlationId 字段可能保留但语义闲置。反例：声明 correlationId 却不在 operation.reply 或 trace 场景中使用，该属性仅提供文档提示，无运行时强制力。

### 8.1.10 components

`components` 是可复用构件的命名空间实体。内部 `$ref`（如 `#/components/messages/X`）与外部 `$ref`（`./contract.yaml#/messages/X`）的 URI 语义由规范明确，但工具支持参差。

components 的身份条件不是某个字段，而是其作为 `$ref` 解析根容器的地位。messages、schemas、operations、parameters 等子命名空间相互独立：可以存在 `#/components/messages/OrderCreated` 与 `#/components/schemas/OrderCreated` 而不冲突。生命周期上，components 随 spec 初始化而存在，并随可复用构件的积累而扩展。外部 `$ref` 的解析策略与版本锁定超出规范范围，是表达力定理 T11 的核心论据。

### 8.1.11 traits

`traits` 是模板/关系型构件，不是运行时实体。其身份由浅合并规则与展开顺序确定；应用后产生 operation/message 的实例属性。多层 traits 的展开顺序是“先列先生效”。

traits 的生命周期是“设计时存在，运行时消失”：代码生成器或 parser 在展开后把 trait 属性合并到 operation/message 实例，运行时不再感知 trait 本身。身份条件上，同一 spec 内 trait 的 `title` 唯一；不同 trait 应用到同一 operation 时，同名属性按展开顺序覆盖。关键反例：若期待 trait 提供继承或多态语义，会得到错误结果——traits 明确否定继承（R7 N），这是 01-86 第 7 个语义陷阱。

```yaml
# trait 浅合并示例：baseTrait 与 overrideTrait 同名属性按顺序覆盖
operationTraits:
  baseTrait:
    description: base
  overrideTrait:
    description: overridden
operations:
  demo:
    traits:
      - $ref: '#/components/operationTraits/baseTrait'
      - $ref: '#/components/operationTraits/overrideTrait'
    # 展开后 description = overridden；无继承链、无多态
```

---

## 8.2 构件间关系七型映射表

本节用 [06 概念关系理论](./06-概念关系理论.md) 的 R1–R7 对构件对做精确判定。表中“方向”按 `源 --关系--> 目标` 书写；所有结论均给出反例检验。

| # | 源构件 | 关系型 | 目标构件 / 概念 | 判定理由 | 反例检验 |
| --- | ------ | ------ | --------------- | -------- | -------- |
| 1 | channels | **R5 A**（关联） | operations | 一个 channel 可被 send / receive 两个 operation 引用；operation 也反向引用 channel | 无 operation 的孤立 channel 仍合法，故非 partOf |
| 2 | operations | **R5 A**（关联） | messages | operation 通过 `messages` 字段引用 message，但 message 可独立于 operation 存在 | 同一 message 被多个 operation 引用，不形成从属 |
| 3 | parameters | **R2 P**（组成） | channels | parameters 是 channel address 模板的组成部分；无 channel 则无 parameters | 无参数的空 channel 仍合法（P 不要求反向必然） |
| 4 | payload | **R2 P**（组成） | messages | payload 是 message 的组成部分；message 可缺 payload 但 payload 不能脱离 message 独立声明 | 仅含 headers 的 message 合法，说明 payload 非必要 |
| 5 | headers | **R2 P**（组成） | messages | headers 是 message 的信封组成部分 | 业务消息可空 headers |
| 6 | correlationId | **R2 P**（组成） | messages | correlationId 作为 message 的关联声明字段存在 | 纯事件消息可缺 correlationId |
| 7 | traits | **R1 S**（特化） | operations | trait 是 operation 的模板；应用 trait 后得到特化 operation 实例（内涵增加：加了 trait 属性） | 同一 trait 应用到不同 operation 产生不同实例 |
| 8 | traits | **R1 S**（特化） | messages | message trait 同理产生特化 message 实例 | 浅合并不保留继承链，故是 S 不是 R2 |
| 9 | action | **R2 P**（组成） | operations | action 是 operation 的取值属性；每个 operation 必有且仅有一个 action | 一个 operation 不能同时是 send 与 receive |
| 10 | reply | **R2 P**（组成） | operations | reply 是 operation 的可选子对象 | 纯 pub/sub operation 可无 reply |
| 11 | reply | **R3 I**（蕴含） | 请求响应模式 | operation 存在 reply 对象 ⇒ 该 operation 参与请求响应模式 | 有 reply 但 address 指向不存在 channel ⇒ 语义失效 |
| 12 | servers | **R5 A**（关联） | channels | channel 通过 `servers` 字段声明可部署的 server | server 不依赖于特定 channel 存在 |
| 13 | components | **R5 A**（关联） | operations | components 存储可复用 operation 定义，通过 `$ref` 关联 | operation 也可内联定义，不必须 components |
| 14 | components | **R5 A**（关联） | messages | components 存储可复用 message 定义 | message 可内联定义 |
| 15 | info | **R2 P**（组成） | AsyncAPI 文档 | info 是契约文档的必需组成部分 | 无 info 的文档不合法 |
| 16 | servers | **R2 P**（组成） | AsyncAPI 文档 | servers 是文档级可选组成部分 | 无 servers 的文档在纯设计阶段可存在 |
| 17 | channels | **R2 P**（组成） | AsyncAPI 文档 | channels 是文档级组成部分 | 空 channels 文档语法合法但无通信语义 |
| 18 | operations | **R2 P**（组成） | AsyncAPI 文档 | operations 是文档级组成部分 | operation 可独立存在但须在文档内 |
| 19 | messages | **R2 P**（组成） | AsyncAPI 文档 | messages 作为内联或引用存在于文档 | message 可在 components 中独立定义 |
| 20 | payload | **R6 R**（实现） | schema / 数据契约 | payload 通过 schema 实现数据契约 | payload 只声明结构，不实现运行时校验（由工具实现） |
| 21 | headers | **R6 R**（实现） | 信封概念 | headers 实现消息信封的协议级表达 | headers 不实现业务语义 |
| 22 | correlationId | **R6 R**（实现） | 关联概念 | correlationId 实现请求/响应/因果链关联 | 关联值实际由传输协议或应用生成 |
| 23 | operations | **R6 R**（实现） | 应用动作概念 | operation 实现 send/receive 应用动作 | 动作的实际执行由客户端运行时实现 |
| 24 | channels | **R6 R**（实现） | topic/queue 概念 | channel 实现抽象传输地址 | 具体映射到 topic 还是 queue 由 binding 决定 |
| 25 | servers | **R6 R**（实现） | broker 端点概念 | server 实现消息中间件端点 | server 不实现 broker 内部状态 |
| 26 | send action | **R4 M**（互斥） | receive action | 同一 operation 的 action 取值不能同时为 send 和 receive | 不同 operation 可分别 send/receive，不冲突 |
| 27 | traits | **R7 N**（否定） | 继承/多态 | traits 采用浅合并，明确否定面向对象式的继承与多态语义 | trait 同名覆盖是替换，不是重写 |
| 28 | binding（operation/message） | **R6 R**（实现） | 交付语义维 | qos、retain 等 binding 字段实现交付语义维度 | binding 只声明，具体语义由 broker 实现 |

**映射说明**：

- R1 S 只出现在 traits 到 operation/message：trait 是“模板→实例”的特化，内涵增加、外延缩小（应用该 trait 的 operation/message 集合小于全部 operation/message）。
- R2 P 大量出现：parameters、payload、headers、correlationId、action、reply 都是其宿主实体的组成部分；info/servers/channels/operations/messages 是 AsyncAPI 文档的组成部分。
- R3 I 只有 reply→请求响应模式：reply 的存在是请求响应模式的充分条件（在规范语义内）。
- R4 M 只有 send action↔receive action：二者在同一 operation 内不可同真。
- R5 A 出现在 channel-operation、operation-message、server-channel、components-operation、components-message 之间：这些是规范中通过字段引用形成的非从属关联。
- R6 R 出现在构件到 MQ/契约概念：构件是这些抽象概念在 AsyncAPI 语言中的落地。
- R7 N 只有 traits→继承：浅合并语义明确排除了继承/多态。

### 8.2.1 关系型分布统计与边界判定

28 对映射中，七型分布如下：

| 关系型 | 出现对数 | 占比 | 典型边界说明 |
| ------ | -------- | ---- | ------------ |
| R2 P（组成） | 11 | 39% | parameters/headers/payload/correlationId/action/reply 是宿主组成部分；info/servers/channels/operations/messages 是文档组成部分 |
| R5 A（关联） | 7 | 25% | channel-operation、operation-message、server-channel、components-operation、components-message |
| R6 R（实现） | 7 | 25% | 构件到抽象 MQ/契约概念的落地 |
| R1 S（特化） | 2 | 7% | traits→operation/message |
| R3 I（蕴含） | 1 | 4% | reply→请求响应模式 |
| R4 M（互斥） | 1 | 4% | send action↔receive action（同一 operation 内） |
| R7 N（否定） | 1 | 4% | traits→继承/多态 |

**边界判定原则**：

1. 若删除源构件后目标构件在规范层面仍可独立存在，则排除 R2 P，考虑 R5 A 或 R6 R。
2. 若源是目标的一般化模板且应用后内涵增加，则判 R1 S；若源是目标的结构部分，则判 R2 P。
3. 若源与目标在同一作用域内不可同真，则判 R4 M；若源明确排除某语义，则判 R7 N。

---

## 8.3 四层验证论证链

本节把 [Testing/06-契约语义测试](../Testing/06-契约语义测试/) 的 L1–L6 映射到 [05 论证方法分类学](./05-论证方法分类学.md) 的论证型，形成统一的验证模型。

| 验证层 | 覆盖内容 | 主论证型（引 05） | 典型工具 | 置信上限 | 层间传递规则 |
| ------ | -------- | ----------------- | -------- | -------- | ------------ |
| L1 语法 | YAML/JSON 格式、必需字段、字段类型 | **演绎**（规范语法规则） | asyncapi-cli validate、Spectral | 【定理】（在规范版本内） | L1 FAIL ⇒ L2–L6 结论无效 |
| L2 schema | JSON Schema 对 payload/headers 的结构约束 | **演绎**（schema→实例） | jsonschema、AsyncAPI parser | 【定理】（schema 固定时） | L2 FAIL ⇒ L3–L6 中涉及该 schema 的语义结论无效 |
| L3 构件规则 | 构件间引用、action/reply 语义、$ref 解析 | **演绎**+**模型论证** | contract-spec-check.sh、kg-query | 【定理】（规则来自规范）/【论证】（工具实现假设） | L3 FAIL ⇒ L4–L6 结论无效 |
| L4 binding | server/channel/operation/message 四级绑定字段与协议映射 | **演绎**+**类比** | bindings-matrix、contract-binding-check.sh | 【论证】（绑定规范+系统能力类比） | L4 FAIL ⇒ L5 实测目标无效、L6 diff 结论存疑 |
| L5 contract test | GWT 断言、真实/容器化执行 | **归纳**（实测样本）+**基准** | test-harness.sh、ASE fixtures | 【论证】（样本充分时）/【估算】（样本不足） | L5 FAIL ⇒ 该语义维度结论降至【估算】，需回溯 L3/L4 |
| L6 diff / 版本 | 契约变更影响、兼容性判定、演化策略 | **溯因**+**规则** | contract-drift-check.sh、doc-self-check | 【论证】（规则+证据） | L6 结论需向下兼容 L1–L5 的历史基线；任一下层 FAIL 则 diff 结论不可接受 |

**层间传递规则形式化**：设第 i 层结论为 C_i，下层基线为 B_i = C_1 ∧ C_2 ∧ ... ∧ C_{i-1}，则 C_i 的可接受性要求 B_i 为真。若 ∃j<i, C_j 被证伪，则 ∀k≥j, C_k 的置信上限降一级（定理→论证，论证→估算），且必须重新验证。

**论证型误用防范**：

- 不可把 L1/L2 的【定理】直接外推到 L5 的业务行为（演绎越界）。
- 不可把 L5 的有限样本结论标为【定理】（归纳不可到定理）。
- L6 的溯因结论必须列出可证伪条件，例如“若新版本的 operation action 语义翻转，则兼容性判定推翻”。

### 8.3.1 实例：MQTT qos 绑定的四层论证

以 MQTT v5 的 `qos` 与 `messageExpiryInterval` 绑定为例，演示四层论证链如何落地。首先用命令行触发 L1 与 L3 检查：

```bash
# L1 语法 + L3 构件规则（bindings-matrix 作为 L4 知识库输入）
asyncapi-cli validate asyncapi-mqtt-example.yaml
./topics/scripts/contract-binding-check.sh asyncapi-mqtt-example.yaml bindings-matrix.md
```

检查流程如下：

- **L1 语法**：asyncapi-cli validate 检查 operation/message 级绑定字段是否存在、类型是否正确。若 `qos: 3` 则 FAIL，因为 qos 取值只能是 0/1/2【定理】。
- **L2 schema**：message payload 的 JSON Schema 检查业务字段类型。若 schema 要求 `sensorId: string` 而实例为整数，则 FAIL。
- **L3 构件规则**：检查 `qos` 字段是否位于 operation/message 级而非 channel 级（mqtt binding 0.2.0 规定 channel 级保留空）。若错放，contract-binding-check.sh 报 WARN/FAIL。
- **L4 binding**：将 `qos: 2` 映射到 MQTT 恰好一次协议语义，将 `messageExpiryInterval` 映射到 TTL 维度。这一步需要 bindings-matrix 与系统能力矩阵类比论证。
- **L5 contract test**：在 MQTT broker 上执行 ASE-012 类断言（过期消息不投递）。样本充分时结论为【论证】，样本不足时为【估算】。
- **L6 diff / 版本**：若后续版本把 `qos: 2` 改为 `qos: 1`，diff 工具需判定这是破坏性变更（交付语义从 exactly-once 降为 at-least-once）。

### 8.3.2 层间失效传导示例

| 失效位置 | 现象 | 传导结果 | 正确处置 |
| -------- | ---- | -------- | -------- |
| L1 语法错误 | `action: sendd` 拼写错误 | L2–L6 全部结论无效 | 先修正语法再进入语义层 |
| L2 schema 错误 | payload 缺少 required 字段 | L3–L6 中涉及该 message 的结论无效 | 修正 schema 后重跑 L3–L6 |
| L3 构件规则错误 | `qos` 写在 channel 级 | L4 绑定映射无意义；L5 测试目标错误；L6 diff 结论存疑 | 按 mqtt binding 0.2.0 下移到 operation/message 级 |
| L4 绑定不匹配 | Kafka spec 使用 MQTT qos 字段 | L5 无法在 Kafka broker 上执行；L6 变更影响误判 | 改用 kafka binding 的对应字段 |
| L5 测试样本不足 | 仅测 10 条消息 | 该维度结论上限【估算】，不能标【论证】 | 扩大样本或明确标注置信度 |

---

## 8.4 表达力定理集

本节给出 12 条构件级可表达性命题，每条包含命题陈述、证明草图、指向 [01-44 DSL 表达力边界与等价转换策略](../topics/01-基础概念与对比分析/01-44-DSL表达力边界与等价转换策略.md) 与 [01-84 消息 DSL 通用模式全集](../topics/01-基础概念与对比分析/01-84-消息DSL通用模式全集.md) 的锚点。

| # | 表达力命题 | 证明草图 | 指向 01-44 / 01-84 |
| --- | ---------- | -------- | ------------------ |
| T1 | `info.version` 可表达文档版本，但**不可表达 API 运行时兼容性策略** | 规范定义 version 为文档版本；兼容性策略（major/minor/patch 语义）是治理约定，需额外 x- 扩展或外部治理文件 | 01-44 §2（版本语义缺口） |
| T2 | `servers` 可表达多环境部署端点，但**不可表达运行时负载均衡或故障转移** | server 只声明 host/protocol/protocolVersion；负载均衡与故障转移由客户端/基础设施实现，超出 spec | 01-84 §3（端点模式） |
| T3 | `channels` 可表达抽象传输地址，但**不可表达通配符订阅的匹配语义** | address 是字符串目标；MQTT `+/#` 通配符是协议级匹配模式，AsyncAPI 无专用通配符构件 | 01-86 §1.86.2、01-84 §4（地址模式） |
| T4 | `parameters` 可表达地址模板变量，但**不可表达变量约束（如取值范围、正则）** | parameter 的 schema 仅描述结构，不保证地址解析阶段的值约束 | 01-44 §3（参数化边界） |
| T5 | `operations` 可表达 send/receive 应用动作，但**不可表达事务边界或 saga 编排** | operation 是单向动作声明；事务与 saga 需跨 operation 的编排语义，规范未提供 | 01-84 §5（编排模式缺口） |
| T6 | `operation.reply` 可表达请求响应模式，但**不可表达超时策略、重试策略或回调幂等要求** | reply 只有 address/channel；超时/重试/幂等需在 x- 扩展或业务层实现 | 01-44 §4（请求响应边界） |
| T7 | `messages` 可表达一次传输的数据单元，但**不可表达消息排序约束或分组键** | 顺序性与分区键由 channel/operation binding（如 Kafka key、Pulsar orderingKey）承载，message 自身无排序构件 | 01-84 §6（消息分组模式） |
| T8 | `payload` 可表达业务载荷结构，但**不可表达 schema 演化规则（forward/backward compatibility）** | payload 引用 schema；兼容性规则属于治理层约定或 x- 扩展 | 01-44 §5（schema 演化边界） |
| T9 | `headers` 可表达协议级信封，但**不可表达头部与 payload 之间的交叉验证规则** | headers 与 payload 是独立 schema；跨字段一致性检查需应用层或 JSON Schema 的 if/then | 01-84 §7（信封模式） |
| T10 | `correlationId` 可表达关联提取表达式，但**不可表达关联超时、关联清理或关联基数** | correlationId 只声明“从哪取”；关联生命周期管理超出规范 | 01-44 §6（关联语义边界） |
| T11 | `components` 可表达可复用命名空间，但**不可表达外部引用的解析策略或版本锁定** | 外部 `$ref` 的 URI 语义明确，但工具支持参差；版本锁定需外部包管理器 | 01-86 §1.86.5、01-44 §7（引用边界） |
| T12 | `traits` 可表达横切组合，但**不可表达条件组合、继承链或多态分发** | traits 语义为浅合并；条件/继承/多态不在规范内 | 01-44 §8（trait 表达力边界） |

**置信说明**：以上 12 条命题中，前半句“可表达 X”在规范有对应构件时为【定理】；后半句“不可表达 Y”基于“规范未定义 Y 构件”的演绎+枚举论证，上限【论证】。若未来 AsyncAPI 版本新增对应构件，命题需修订。

### 8.4.1 定理置信上限与可证伪条件

每条表达力命题的置信上限由论证型决定：

| 命题部位 | 论证型 | 置信上限 | 可证伪条件 |
| -------- | ------ | -------- | ---------- |
| “可表达 X” | 演绎（规范定义） | 【定理】 | 规范版本漂移或官方重新定义 X 构件 |
| “不可表达 Y” | 演绎（枚举规范构件）+ 论证（覆盖缺口） | 【论证】 | 官方新增 Y 构件或本项目 x- 扩展被社区采纳 |
| 指向 01-44/01-84 的锚点 | 类比（DSL 模式映射） | 【论证】 | 01-44/01-84 自身修订 |

**复合置信规则**：单条定理的整体置信 = min(“可表达”置信, “不可表达”置信, 锚点置信) = min(定理, 论证, 论证) = **【论证】**。因此 8.4 的 12 条命题整体上限为【论证】，仅局部“可表达 X”可标【定理】。

---

## 8.5 参考来源

- 项目内：
  - [06 概念关系理论](./06-概念关系理论.md)：R1–R7 七型的形式性质与机推规则。
  - [05 论证方法分类学](./05-论证方法分类学.md)：演绎/归纳/类比/溯因/案例/基准/形式七种论证型及其置信映射。
  - [01-86 AsyncAPI 构件语义全书](../topics/01-基础概念与对比分析/01-86-AsyncAPI构件语义全书.md)：11 构件的完整语义与 8 个语义陷阱。
  - [bindings-matrix](../Testing/06-契约语义测试/01-契约规格/bindings-matrix.md)：六系统四级绑定字段覆盖矩阵与 x- 扩展登记簿。
  - [01-44 DSL 表达力边界与等价转换策略](../topics/01-基础概念与对比分析/01-44-DSL表达力边界与等价转换策略.md)：表达力边界、等价转换与 x- 扩展策略。
  - [01-84 消息 DSL 通用模式全集](../topics/01-基础概念与对比分析/01-84-消息DSL通用模式全集.md)：消息 DSL 的通用模式与缺口映射。
  - [Testing/06-契约语义测试](../Testing/06-契约语义测试/)：L1–L6 验证体系与 ASE 断言库。
- 外部：
  - [AsyncAPI 3.0.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
  - [AsyncAPI 3.1.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.1.0)（2026-01-31 发布，minor 零破坏，唯一新增 ROS 2 bindings；仓基线 2026-11-21 起）
  - [AsyncAPI Bindings](https://www.asyncapi.com/docs/reference/bindings)

---

**最后更新**: 2026-11-18
