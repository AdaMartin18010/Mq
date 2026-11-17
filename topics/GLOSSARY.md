# 消息队列术语表（Glossary）

## A

**Agent Skills（SKILL.md）** - AI 代理技能开放标准

- 由 Anthropic 于 2025-10 发布、2025-12-18 以开放规范发布于 agentskills.io、2026-10 捐赠给 AAIF（Linux 基金会）
- 技能 = 含 SKILL.md 的目录（YAML frontmatter + Markdown 指令），渐进披露三层加载
- 本项目 AI_Skill 系列对齐该标准制作 MQ 技能（详见 topics/AI_Skill/）

**ACK (Acknowledgment)** - 确认机制

- **Kafka**: acks=0/1/-1，控制消息确认级别
- **MQTT**: PUBACK/PUBREC/PUBCOMP，QoS确认报文
- **NATS**: Consumer ACK，JetStream消息确认

**AP系统 (Availability-Partition tolerance)** - 可用性-分区容忍系统

- **NATS Core**: AP系统，优先可用性和性能
- **MQTT**: AP系统，主从模式保证可用性

**At-Least-Once** - 至少一次投递

- **Kafka**: acks=1，保证消息至少送达一次
- **MQTT**: QoS 1，至少一次投递
- **NATS JetStream**: 默认投递语义

**At-Most-Once** - 最多一次投递

- **Kafka**: acks=0，不保证投递
- **MQTT**: QoS 0，最多一次投递
- **NATS Core**: 默认投递语义

**A2A** - Agent-to-Agent Protocol

- Google 提出的智能体互操作协议，智能体通过 Agent Card 描述能力并协商调用

**ADR (Architecture Decision Record)** - 架构决策记录

- 记录关键架构决策及其上下文、后果的标准化文档

**AIOps** - AI for IT Operations

- 利用 AI/ML 进行异常检测、根因分析、容量预测的智能运维方法

**AMQP 1.0** - Advanced Message Queuing Protocol 1.0

- OASIS 标准化的二进制消息协议，支持多种 MQ 实现互操作

## B

**Backpressure** - 背压

- 消费端向生产端反馈流控信号，防止下游被压垮
- Reactive Streams、gRPC、RSocket 均内置背压机制

**BPMN 2.0** - Business Process Model and Notation 2.0

- 业务流程建模标注标准，常与 Zeebe、Temporal 等引擎配合使用

**Broker** - 消息代理

- **Kafka**: Broker节点，存储Partition
- **MQTT**: Broker服务器，管理连接和路由
- **NATS**: Server节点，路由消息
- **Pulsar**: Broker节点（无状态），负责消息路由和负载均衡

## C

**CAP定理** - 一致性、可用性、分区容忍性

- **Kafka**: CP系统（一致性+分区容忍）
- **NATS Core**: AP系统（可用性+分区容忍）
- **NATS JetStream**: CP系统（Raft共识）
- **Pulsar**: CP系统（BookKeeper Quorum共识）

**Consumer** - 消费者

- **Kafka**: Consumer从Broker拉取消息
- **MQTT**: Subscriber订阅Topic接收消息
- **NATS**: Subscriber订阅Subject接收消息
- **Pulsar**: Consumer订阅Topic，支持Exclusive/Shared/Failover/Key_Shared四种订阅模式

**Consumer Group** - 消费者组

- **Kafka**: 多个Consumer组成Group，实现负载均衡
- **MQTT**: 无Consumer Group概念
- **NATS**: Queue Group实现类似功能

**CP系统 (Consistency-Partition tolerance)** - 一致性-分区容忍系统

- **Kafka**: CP系统，ISR机制保证一致性
- **NATS JetStream**: CP系统，Raft共识算法
- **Pulsar**: CP系统，BookKeeper Quorum共识算法

**CBV** - Core Business Vocabulary

- EPCIS 标准的业务词汇核心规范，用于统一物品追踪语义

**Claim-Check** - 索赔检查模式

- EIP 模式：消息体过大时只发票据/引用，内容存储在外部存储

**Cluster Linking** - 集群链接

- Confluent Kafka 集群间 topic 级实时联邦与灾备复制

**Competing Consumers** - 竞争消费者模式

- EIP 模式：多个消费者实例争抢同队列消息以实现水平扩展

**Context Mapping** - 上下文映射

- 领域驱动设计中界定不同限界上下文及其集成关系的模式

**CQRS** - Command Query Responsibility Segregation

- 读写模型分离：命令路径与查询路径使用不同数据模型

## D

**Dapr Workflow** - Dapr 工作流

- Dapr 侧车提供的有状态、持久化工作流构建块

**Dead Letter Queue (DLQ)** - 死信队列

**durable execution** - 持久执行

- 执行状态自动持久化，失败后可从断点恢复的执行模型（如 Temporal）

- 处理失败消息的队列
- Kafka通过Consumer异常处理实现
- NATS JetStream支持消息重试和DLQ
- **Pulsar**: 原生支持死信队列，自动处理失败消息

## E

**Exactly-Once** - 恰好一次投递

- **Kafka**: acks=-1 + 幂等性 + 事务
- **MQTT**: QoS 2，四步握手保证
- **NATS JetStream**: 事务模式支持
- **Pulsar**: 事务模式支持，保证恰好一次投递

**eKuiper** - eKuiper

- 边缘流处理引擎，常与 MQTT/Kafka 配合做边缘过滤与聚合

**Envelope Encryption** - 信封加密

- 数据密钥加密数据，主密钥再加密数据密钥的嵌套加密方案

**EPCIS** - Electronic Product Code Information Services

- GS1 物品追踪事件标准，常与 CBV 一起使用

**Event Sourcing** - 事件溯源

- 以事件流为系统真相源，状态通过重放事件重建

**Event Storming** - 事件风暴

- 领域事件驱动的协作式设计工作坊，用于发现业务边界与聚合

**Event Source Mapping** - 事件源映射

- 云函数/Serverless 中从 MQ/流自动触发函数调用的映射配置

**EventCatalog** - EventCatalog

- 事件驱动架构的发现、治理与文档化平台

## F

**FaaS** - Function as a Service

- 函数即服务，事件源映射常触发云函数执行

**FHIR** - Fast Healthcare Interoperability Resources

- 医疗健康数据互操作标准

**Follower** - 跟随者

**franz-go** - franz-go

- 高性能 Kafka Go 客户端库

- **Kafka**: Partition的副本节点，从Leader同步数据
- **MQTT**: 无Follower概念
- **NATS**: 所有节点对等，无主从之分

## G

**Gossip协议** -  gossip协议

- **NATS**: 用于集群自动发现和状态同步
- 无中心化，节点间相互通信

**gRPC streaming** - gRPC Streaming

- gRPC 支持的服务端流、客户端流与双向流

## H

**High Watermark (HW)** - 高水位线

- **Kafka**: Consumer只能消费到HW之前的消息
- 保证已提交消息的可见性

**Hot Standby** - 热备

- **MQTT**: 主从模式中的备用Broker
- 主Broker故障时自动切换

## I

**ISR (In-Sync Replicas)** - 同步副本集合

- **Kafka**: 与Leader保持同步的副本集合
- 用于保证数据一致性和可用性

**Idempotent Receiver** - 幂等接收者模式

- EIP 模式：接收者通过去重键保证同一消息多次处理结果一致

**ISO 20022** - ISO 20022

- 金融业通用 XML/JSON 报文标准

## J

**Jakarta Messaging** - Jakarta Messaging

- JMS 在 Jakarta EE 中的继任规范名称

**JMS (Java Message Service)** - Java 消息服务

- Java EE/Jakarta EE 消息 API 规范

**JetStream** - NATS持久化流处理

- 基于Raft共识算法
- 提供流存储和消息重放功能

## K

**KeepAlive** - 保活机制

- **MQTT**: 心跳检测，保持连接活跃
- **NATS**: 连接心跳，检测连接状态

**Knative** - Knative

- K8s 上的 Serverless 工作负载与事件抽象

**KurrentDB** - KurrentDB

- 以事件存储为核心的数据库（原 EventStoreDB）

## L

**leafnode** - Leafnode

- NATS 边缘 leaf 节点，用于 Supercluster 联邦中的边缘接入

**Leader** - 领导者

- **Kafka**: Partition的主节点，处理读写请求
- **NATS JetStream**: Raft算法选出的Leader

**LWT (Last Will Testament)** - 遗嘱消息

- **MQTT**: 设备异常断开时自动发布的消息
- 用于设备状态监控

## M

**Message Queue** - 消息队列

- 异步消息传递机制
- 解耦生产者和消费者

**MirrorMaker** - Kafka镜像工具

- 用于Kafka集群间数据复制
- 支持跨数据中心同步

**MCP (Model Context Protocol)** - 模型上下文协议

- Anthropic 提出的 AI 模型与外部工具/资源交互的开放协议

**Messaging Semantic Conventions** - 消息语义约定

- OpenTelemetry 对消息系统追踪与指标的标准化语义

**Microcks** - Microcks

- 异步 API 与事件契约的 mock、测试与 CI 集成平台

**MirrorMaker 2** - MirrorMaker 2

- Kafka 集群间数据镜像与灾备复制工具

**Modelina** - Modelina

- AsyncAPI 通用代码与数据模型生成器

## N

**NATS** - 云原生消息系统

- CNCF项目
- 简单、高性能、云原生友好

## O

**Offset** - 偏移量

- **Kafka**: 消息在Partition中的位置
- 用于消息定位和消费进度管理

**OSR (Out-of-Sync Replicas)** - 不同步副本

- **Kafka**: 与Leader不同步的副本
- 可能因网络延迟或节点故障导致

**OIDC** - OpenID Connect

- 基于 OAuth 2.0 的身份认证层

**OpenADR** - Open Automated Demand Response

- 能源自动需求响应通信规范

**Open Workflow Specification** - Open Workflow Specification

- 开放工作流规范倡议，旨在统一工作流定义

**OPC UA PubSub** - OPC UA Publish-Subscribe

- OPC UA 的发布订阅扩展，常用于工业物联网

## P

**Partition** - 分区

**Projection** - 投影

- 事件溯源中从事件流构建的读取模型或视图

- **Kafka**: Topic的物理分片
- **Pulsar**: Topic的逻辑分片（Ledger），自动管理
- 实现并行处理和水平扩展

**Producer** - 生产者

- **Kafka**: 发送消息到Broker
- **MQTT**: Publisher发布消息到Topic
- **NATS**: Publisher发布消息到Subject
- **Pulsar**: Producer发送消息到Topic，支持批量发送和压缩

**Pub/Sub** - 发布-订阅模式

- 消息发布者与订阅者解耦
- 支持一对多消息分发

## Q

**QoS (Quality of Service)** - 服务质量

- **MQTT**: QoS 0/1/2，不同可靠性级别
- QoS 0: 最多一次
- QoS 1: 至少一次
- QoS 2: 恰好一次

**Queue Group** - 队列组

- **NATS**: 多个Subscriber组成队列组
- 实现负载均衡，消息只投递给一个Subscriber

**Queue-Based Load Leveling** - 基于队列的负载均衡模式

- EIP 模式：用队列削峰填谷，解耦生产与消费速率

## R

**Raft** - Raft共识算法

- **NATS JetStream**: 用于保证数据一致性
- 分布式一致性算法

**Rebalance** - 重平衡

- **Kafka**: Consumer Group重新分配Partition
- 触发条件：Consumer加入/离开、Partition变化

**Retention** - 保留策略

- **Kafka**: 消息保留时间或大小限制
- **NATS JetStream**: Stream保留策略
- **Pulsar**: Namespace级保留策略，支持分层存储自动卸载

**Reactive Messaging** - Reactive Messaging

- Eclipse MicroProfile 反应式消息规范

**Reactive Streams** - Reactive Streams

- 异步流处理规范，定义 Publisher/Subscriber/Subscription

**RSocket** - RSocket

- 支持背压的二进制应用层协议

## S

**Segment** - 段文件

- **Kafka**: Log文件按大小或时间切分
- 便于管理和清理

**Share Group** - 共享组

- **Kafka**: KIP-932（Queues for Kafka）引入，多个消费者协作消费同一分区的不同记录，Broker 按记录跟踪获取/确认/重试状态（`__share_group_state` 内部主题），提供队列语义
- **状态**: 4.0 Early Access → 4.1 Preview → 4.2 计划 GA
- **限制**: 不保证分区顺序；需要顺序时仍用传统 Consumer Group + Key 路由

**Subject** - 主题

- **NATS**: 消息路由的主题名称
- 支持通配符匹配

**Subscription** - 订阅

- **MQTT**: 订阅Topic接收消息
- **NATS**: 订阅Subject接收消息
- **Pulsar**: Subscription订阅Topic，支持Exclusive/Shared/Failover/Key_Shared四种模式

**Sequential Convoy** - 顺序护送模式

- EIP 模式：保证相关消息按顺序被同一处理单元消费

**Sigstore** - Sigstore

- 软件制品签名与验证的开放生态

**Span** - Span

- 分布式追踪中的一个工作单元

**Specification Extensions** - Specification Extensions

- AsyncAPI/OpenAPI 中以 `x-` 为前缀的扩展字段机制

**Sparkplug B** - Sparkplug B

- MQTT 工业物联网 payload 规范

**Spectral** - Spectral

- Stoplight 出品的 AsyncAPI/OpenAPI 规范检查器

**SPIFFE/SPIRE** - SPIFFE/SPIRE

- 云原生工作负载身份框架及其实现，签发 SVID

**Springwolf** - Springwolf

- 从 Spring Boot 代码自动生成 AsyncAPI 文档与 UI

**SSE** - Server-Sent Events

- 服务器单向推送的 HTTP 流协议

**STOMP** - Simple Text Oriented Messaging Protocol

- 简单文本定向消息协议

**Supercluster** - Supercluster

- NATS 多集群联邦架构

**SVID** - SPIFFE Verifiable Identity Document

- SPIFFE 体系中的可验证身份文档/证书

## T

**Temporal** - Temporal

- 持久化执行的工作流编排平台

**Topic** - 主题

**traceparent** - traceparent

- W3C 分布式追踪上下文头

**Transactional Outbox** - 事务性发件箱模式

- EIP 模式：事务内写 Outbox 表，再由 relay 投递到 MQ

- **Kafka**: 消息的逻辑分类
- **MQTT**: 消息的主题名称，支持层级结构
- **Pulsar**: Topic位于Namespace下，支持多租户层级结构（tenant/namespace/topic）

**Transaction** - 事务

- **Kafka**: 支持跨Partition事务
- **NATS JetStream**: 支持事务模式
- **Pulsar**: 支持跨Topic事务，保证恰好一次投递

## U

**Under-Replicated** - 欠副本

- **Kafka**: Partition副本数不足
- 影响可用性和数据安全性

**Upcaster** - Upcaster

- 事件溯源中将旧版本事件升级为新版本的处理组件

## V

**Version** - 版本

- **MQTT**: 3.1.1 / 5.0
- **Kafka**: 持续演进，支持KRaft模式
- **NATS**: 持续更新，向后兼容
- **Pulsar**: 持续演进，支持多协议适配器（Kafka/MQTT/AMQP）

**Virtual Threads** - Virtual Threads

- JDK 21+ 轻量级线程，提升 IO 密集型 MQ 客户端并发

## W

**WebSocket** - WebSocket

- 全双工应用层流协议，MQTT over WebSocket 常见

**WebTransport** - WebTransport

- 基于 HTTP/3 的低延迟双向传输框架

**Wildcard** - 通配符

- **MQTT**: `+` (单层) / `#` (多层)
- **NATS**: `*` (单层) / `>` (多层)

**Wire Tap** - 线路窃听模式

- EIP 模式：在不影响主流程的情况下复制消息用于审计或调试

## Z

**Zero Trust** - 零信任

- 永不信任、持续验证的安全架构模型

**Zeebe** - Zeebe

- Camunda 云原生工作流引擎

**ZooKeeper** - 协调服务

- **Kafka**: 元数据管理和Controller选举
- Kafka 3.0+支持KRaft模式，逐步替代ZK

---

**参考文档**:

- [Kafka术语表](https://kafka.apache.org/documentation/#terminology)
- [MQTT规范](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [NATS文档](https://docs.nats.io/)
- [Pulsar文档](https://pulsar.apache.org/docs/)
- [OpenTelemetry Messaging Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/messaging/messaging-spans/)

---

**最后更新**: 2026-11-18
