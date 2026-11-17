# 1.42 JMS、AMQP 与传统企业消息标准

> **置信口径声明**: 本文协议/规范语义优先引用 OASIS、ISO/IEC、Jakarta EE 官方文档，标【定理】；实现版本、生态现状来自各项目官方发布页或 Maven Central，标【论证】；无公开溯源的经验数字标【估算】。
> **时效声明**: 本文事实基于 Jakarta EE、Apache ActiveMQ/Artemis/Qpid、RabbitMQ、OASIS AMQP 官方发布信息，核实至 2026-11。
> **定位声明**: 本文为 01 系列深度分析专章，承接并深化 [01-30-事件互操作标准分析](01-30-事件互操作标准分析.md) 中“AMQP 1.0 与 AMQP 0-9-1 的定位”一节，聚焦 JMS/Jakarta Messaging、AMQP 1.0、STOMP 等传统企业消息标准的对象模型、协议语义与遗留系统集成选型。阅读前建议先回顾 [01-16-MQTT-5.0新特性深度分析](01-16-MQTT-5.0新特性深度分析.md)、[01-25-Kafka-4.0新时代与队列语义分析](01-25-Kafka-4.0新时代与队列语义分析.md)、[01-30-事件互操作标准分析](01-30-事件互操作标准分析.md)。

----

## 目录

- [1.42 JMS、AMQP 与传统企业消息标准](#142-jmsamqp-与传统企业消息标准)
  - [目录](#目录)
  - [1.42.1 JMS / Jakarta Messaging](#1421-jms--jakarta-messaging)
    - [API 对象模型](#api-对象模型)
    - [PTP 与 Pub/Sub 域](#ptp-与-pubsub-域)
    - [消息确认模式](#消息确认模式)
    - [消息类型与 JMS 2.0 增强](#消息类型与-jms-20-增强)
    - [javax → jakarta 包名迁移的兼容性影响](#javax--jakarta-包名迁移的兼容性影响)
  - [1.42.2 JMS 实现生态](#1422-jms-实现生态)
    - [ActiveMQ Classic 与 Artemis](#activemq-classic-与-artemis)
    - [Qpid JMS 与商业 JMS](#qpid-jms-与商业-jms)
    - [Spring JMS 模板用法](#spring-jms-模板用法)
  - [1.42.3 AMQP 1.0 协议深度](#1423-amqp-10-协议深度)
    - [与 AMQP 0-9-1 的架构差异](#与-amqp-0-9-1-的架构差异)
    - [Link 与 Credit-based 背压](#link-与-credit-based-背压)
    - [Settlement 与投递语义映射](#settlement-与投递语义映射)
  - [1.42.4 AMQP 1.0 实现现状](#1424-amqp-10-实现现状)
  - [1.42.5 STOMP](#1425-stomp)
  - [1.42.6 遗留系统集成选型](#1426-遗留系统集成选型)
    - [何时仍选 JMS / AMQP 1.0](#何时仍选-jms--amqp-10)
    - [与现代协议对比矩阵](#与现代协议对比矩阵)
    - [迁移建议](#迁移建议)
  - [1.42.7 参考来源](#1427-参考来源)

----

## 1.42.1 JMS / Jakarta Messaging

Java Message Service（JMS）最初由 Sun 于 1998 年提出，目标是给 Java 应用提供统一的消息中间件编程接口。Jakarta Messaging 是 JMS 在 Eclipse Jakarta EE 下的继任名称，核心 API 语义保持稳定，主要变化发生在包名与发布归属上。

### API 对象模型

JMS API 采用经典的生产者-消费者对象层次：

| 对象 | 职责 | 生命周期要点 |
| ---- | ---- | ------------ |
| `ConnectionFactory` | 创建 `Connection` 的工厂 | 通常通过 JNDI 或 CDI/Spring 注入，线程安全 |
| `Connection` | 代表到消息服务器的物理连接 | 创建后需 `start()`，通常一个应用长驻 |
| `Session` | 单线程上下文，创建消息、生产者和消费者 | 非线程安全，事务与确认模式在此绑定 |
| `MessageProducer` | 向 `Destination`（Queue/Topic）发送消息 | 可针对 Destination 创建，也可创建时指定 |
| `MessageConsumer` | 从 `Destination` 接收消息 | 支持同步 `receive()` 与异步 `MessageListener` |
| `Destination` | Queue（PTP）或 Topic（Pub/Sub）的抽象 | 由 Session 创建或 JNDI 查找 |

【论证】上述对象模型自 JMS 1.1 起即保持稳定，Jakarta Messaging 3.1 规范文档仍沿用同一结构，仅包名由 `javax.jms` 改为 `jakarta.jms`。

### PTP 与 Pub/Sub 域

JMS 定义两种消息域：

- **PTP（Point-to-Point）**：每条消息只有一个消费者；消息被消费后从队列移除；生产者与消费者之间没有时间耦合。
- **Pub/Sub（发布/订阅）**：每条消息可广播给多个订阅者；订阅者又分为**持久订阅（Durable）**与**非持久订阅（Non-durable）**。

JMS 2.0 引入了**共享订阅（Shared Subscription）**，允许多个消费者共享同一个订阅，从而在同组内实现负载均衡，同时保留发布/订阅的语义。共享持久订阅通过 `Session.createSharedDurableConsumer()` 创建，共享非持久订阅通过 `Session.createSharedConsumer()` 创建。

### 消息确认模式

`Session` 创建时指定确认模式，直接影响可靠性、吞吐与重复消费风险：

| 模式 | 常量 | 语义 | 适用场景 |
| ---- | ---- | ---- | -------- |
| 自动确认 | `AUTO_ACKNOWLEDGE` | `receive()` 返回或 `onMessage()` 返回成功后自动确认 | 普通场景，简单但可能丢消息 |
| 客户端确认 | `CLIENT_ACKNOWLEDGE` | 显式调用 `message.acknowledge()`，确认会顺带确认该 Session 已消费的所有消息 | 需要业务处理完成后再确认 |
| 允许重复 | `DUPS_OK_ACKNOWLEDGE` | 延迟确认，允许少量重复，换取更高吞吐 | 幂等消费者、高吞吐场景 |
| 事务 | `SESSION_TRANSACTED` | 通过 `commit()`/`rollback()` 批量提交或回滚一组消息 | 需要原子性的场景 |

【定理】`CLIENT_ACKNOWLEDGE` 下，调用单条消息的 `acknowledge()` 会确认该 Session 所有已消费消息，这一行为由 Jakarta Messaging 3.1 规范定义，属于 API 级约定。

### 消息类型与 JMS 2.0 增强

JMS 定义了五种消息类型：

| 类型 | 承载内容 | 典型用途 |
| ---- | -------- | -------- |
| `TextMessage` | `String` | JSON/XML 文本事件 |
| `BytesMessage` | 字节流 | 二进制 payload、Avro/Protobuf |
| `ObjectMessage` | 可序列化 Java 对象 | 传统 Java 内部通信，不建议跨版本使用 |
| `MapMessage` | 键值对（Java 原始类型） | 结构化参数传递 |
| `Message` | 仅头信息，无 body | 心跳、通知类场景 |

JMS 2.0 相对 1.1 的重要增强包括：

1. **简化 API**：`JMSContext` 将 `Connection`、`Session` 合并，支持 try-with-resources。
2. **共享订阅**：解决多个消费者并发消费同一主题的问题。
3. **投递延迟（Delivery Delay）**：`MessageProducer.setDeliveryDelay(long)` 支持延迟投递。
4. **异步发送回调**：`CompletionListener` 支持异步发送并感知结果。

### javax → jakarta 包名迁移的兼容性影响

Jakarta EE 9（2019 年发布）将 `javax.*` 命名空间整体迁移到 `jakarta.*`。对 JMS 的影响如下：

| 维度 | JMS 2.0（Java EE 8） | Jakarta Messaging 3.0/3.1（Jakarta EE 9/10/11） |
| ---- | -------------------- | ------------------------------------------------ |
| 包名 | `javax.jms` | `jakarta.jms` |
| Maven 坐标 | `javax.jms:javax.jms-api:2.0.1` | `jakarta.jms:jakarta.jms-api:3.1.0` |
| 最小 Java 版本 | Java 7/8 | Java 11（3.1） |
| 兼容实现 | ActiveMQ Classic、HornetQ 等旧版 | ActiveMQ Artemis、Eclipse OpenMQ 6.x、Qpid JMS 2.x |

【论证】Jakarta Messaging 3.1 随 Jakarta EE 10 发布，并在 Jakarta EE 11 中保持不变（仍为 3.1）。Jakarta EE 11 平台规范于 2025-06-17 完成 Release Review，最小 Java 版本提升至 Java 17。

迁移代价主要体现在：

- 代码层面：所有 `import javax.jms.*` 改为 `import jakarta.jms.*`。
- 依赖层面：需替换 Maven/Gradle 坐标，并检查应用服务器是否提供 Jakarta EE 10/11 兼容实现。
- 运行时层面：同一 JVM 内不建议混用 `javax.jms` 与 `jakarta.jms` 客户端，否则会出现类加载冲突。

----

## 1.42.2 JMS 实现生态

### ActiveMQ Classic 与 Artemis

Apache ActiveMQ 家族目前分为两条线：

| 项目 | 定位 | 当前主版本（2026-11） | 核心特点 |
| ---- | ---- | --------------------- | -------- |
| ActiveMQ Classic | 传统 Java 消息代理，兼容 JMS 1.1/2.0 | 5.19.x（Active） | 成熟稳定，协议支持丰富（OpenWire、AMQP、MQTT、STOMP） |
| ActiveMQ Artemis | 下一代核心，基于 HornetQ 捐赠代码 | 2.42.x（Maven Central） | 支持 JMS 2.0 / Jakarta Messaging 3.1，核心协议 AMQP 1.0 |

【论证】ActiveMQ Classic 5.19.0 于 2025-03-11 发布，5.19.x 是当前 Active 维护线；ActiveMQ Artemis 2.42.0 已于 2025-07-18 发布到 Maven Central。

Artemis 采用**异步日志 journal** 与**无锁 Ring Buffer** 架构，目标是高吞吐与现代协议原生支持。官方建议新用户优先选择 Artemis，Classic 主要服务存量用户。

### Qpid JMS 与商业 JMS

| 实现 | 协议基础 | JMS 包 | 典型用途 |
| ---- | -------- | ------ | -------- |
| Apache Qpid JMS | AMQP 1.0 | `jakarta.jms`（2.x）/ `javax.jms`（1.x） | 跨厂商 AMQP 1.0 Broker 的 JMS 客户端 |
| IBM MQ | 原生 + AMQP | JMS 2.0 / Jakarta Messaging | 金融核心、主机集成 |
| Oracle AQ | 数据库消息 | JMS 标准 API | Oracle 数据库生态内部异步 |
| Eclipse OpenMQ | Open Message Queue | Jakarta Messaging 3.1 | GlassFish 参考实现 |

【论证】Apache Qpid JMS 2.7.0 于 2025-02 发布，构建在 Qpid Proton 0.40.0（2024-11）之上，支持 Jakarta Messaging 3.1。Qpid JMS 1.x 线仍支持 JMS 2.0（`javax.jms`）。

### Spring JMS 模板用法

Spring 对 JMS 的封装主要通过 `JmsTemplate` 与 `@JmsListener`。以下示例以 ActiveMQ Artemis + Jakarta Messaging 3.1 为例：

```java
import jakarta.jms.ConnectionFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
import org.springframework.jms.core.JmsTemplate;

@Configuration
@EnableJms
public class JmsConfig {

    @Bean
    public JmsTemplate jmsTemplate(ConnectionFactory connectionFactory) {
        JmsTemplate template = new JmsTemplate(connectionFactory);
        template.setDefaultDestinationName("orders.queue");
        template.setSessionTransacted(true);   // 启用事务
        return template;
    }

    @Bean
    public DefaultJmsListenerContainerFactory jmsListenerContainerFactory(
            ConnectionFactory connectionFactory) {
        DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setSessionAcknowledgeMode(jakarta.jms.Session.CLIENT_ACKNOWLEDGE);
        return factory;
    }
}
```

生产者发送：

```java
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

@Component
public class OrderProducer {
    private final JmsTemplate jmsTemplate;

    public OrderProducer(JmsTemplate jmsTemplate) {
        this.jmsTemplate = jmsTemplate;
    }

    public void send(String orderJson) {
        jmsTemplate.convertAndSend("orders.queue", orderJson);
    }
}
```

消费者监听：

```java
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Component
public class OrderConsumer {

    @JmsListener(destination = "orders.queue", containerFactory = "jmsListenerContainerFactory")
    public void receive(String orderJson) {
        // 业务处理
    }
}
```

----

## 1.42.3 AMQP 1.0 协议深度

### 与 AMQP 0-9-1 的架构差异

【定理】AMQP 1.0 是 OASIS 标准（2012-10-29 批准），并于 2014 年被 ISO/IEC 采纳为国际标准 ISO/IEC 19464:2014；AMQP 0-9-1 从未成为正式国际标准，是 RabbitMQ 早期采用的行业事实协议。

| 对比项 | AMQP 0-9-1 | AMQP 1.0 |
| ---- | ---- | ---- |
| 标准状态 | 行业事实标准 | OASIS / ISO/IEC 19464 国际标准 |
| 模型 | Exchange → Binding → Queue 的中心化路由 | 基于 Link 的对等传输，broker 语义与协议解耦 |
| RabbitMQ 支持 | 原生母语 | RabbitMQ 4.0 起原生默认启用 |
| 默认端口 | 5672 | 5672（协议协商区分版本） |
| 互操作重点 | 同 RabbitMQ 生态 | 跨厂商（Azure Service Bus、ActiveMQ Artemis、Solace） |

AMQP 1.0 并非 0-9-1 的“升级补丁”：二者 wire 协议、帧格式、对象模型完全不同。1.0 将自身定位为**传输中立的消息传递协议**，不强制规定 broker 必须提供 exchange/queue/binding 等结构；broker 只需实现节点（node）与链路（link）的抽象。

### Link 与 Credit-based 背压

AMQP 1.0 的核心传输结构是：

- **Connection**：TCP/TLS 之上的安全认证通道。
- **Session**：连接内的多路复用通道，保证帧顺序。
- **Link**：发送者（sender）与接收者（receiver）之间的单向消息通道；分为 sending link 与 receiving link。

流量控制通过 **credit-based** 机制实现：

- 接收者通过 `flow` 帧向发送者授予 **link credit**。
- 发送者只能在 credit > 0 时发送消息。
- 当接收者处理不过来时，不再发放 credit，发送者自动停止发送，实现背压。

```text
Receiver -> flow(credit=10) -> Sender
Sender   -> transfer(message) -> Receiver
Receiver -> flow(credit=9, delivery-count++) -> Sender
```

【定理】Credit-based flow control 是 AMQP 1.0 核心规范的一部分，定义于 OASIS AMQP 1.0 Part 2（Transport）与 Part 3（Messaging）。

### Settlement 与投递语义映射

AMQP 1.0 通过 settlement 状态机表达消息是否被“最终处理”：

| 语义 | AMQP 1.0 配置 | 说明 |
| ---- | ------------- | ---- |
| At-most-once | `sender-settle-mode=settled` + `receiver-settle-mode=first` | 发送后即认为完成，不重试，可能丢失 |
| At-least-once | `sender-settle-mode=unsettled` + `receiver-settle-mode=first` | 接收者确认后才 settled，失败则重发 |
| Exactly-once | `sender-settle-mode=unsettled` + `receiver-settle-mode=second` | 双方均 settled 才最终完成 |

【定理】上述 settlement 语义由 OASIS AMQP 1.0 Part 3 定义；exactly-once 要求发送端与接收端均参与两阶段确认，且需要消息去重机制配合。

需要注意：AMQP 1.0 的 exactly-once 是**协议层面的恰好一次 settlement**，如果应用端重复处理已 settlement 但未去重的消息，仍可能出现业务层面的重复。该去重通常需要结合 `message-id` 或 `delivery-tag` 实现。

----

## 1.42.4 AMQP 1.0 实现现状

AMQP 1.0 的跨厂商互操作性是其最大优势。当前主要实现支持如下：

| Broker / 云服务 | AMQP 1.0 支持状态 | 备注 |
| --------------- | ----------------- | ---- |
| ActiveMQ Artemis | 原生支持 | 核心协议之一，支持 JMS over AMQP 1.0 |
| RabbitMQ 4.0+ | 原生默认启用 | 不再依赖插件，与 0-9-1 共用 5672 端口 |
| RabbitMQ 3.x | 插件支持 | 需启用 `rabbitmq_amqp1_0` 插件 |
| Azure Service Bus | 原生支持 | 官方推荐协议，支持 TLS + SASL |
| Azure Event Hubs | 原生支持 | Kafka 协议并存，AMQP 1.0 用于高级场景 |
| Solace PubSub+ | 原生支持 | 提供 AMQP 1.0 协议一致性声明 |
| Apache Qpid Broker-J | 原生支持 | 参考级 AMQP 1.0 broker |

【论证】RabbitMQ 4.0 于 2024-09 发布，AMQP 1.0 作为核心协议默认启用；Azure Service Bus 与 Event Hubs 官方文档均将 AMQP 1.0 列为首选协议。

客户端侧：

- **RabbitMQ 官方 AMQP 1.0 Java 客户端**：随 RabbitMQ 4.0 推出，推荐新应用使用。
- **Apache Qpid Proton**：C 语言实现的协议引擎，提供 Java、Python、C++ 等绑定。
- **Apache Qpid JMS**：在 Qpid Proton 之上实现 Jakarta Messaging API，可对接任何 AMQP 1.0 broker。

----

## 1.42.5 STOMP

STOMP（Simple/Streaming Text Oriented Messaging Protocol）是一种**简单文本帧协议**，设计目标是让脚本语言与浏览器端能快速接入消息代理。最新规范为 **STOMP 1.2**，于 2012-10 发布。

STOMP 帧结构简单，以命令行开头，后跟 header 键值对，最后为 body：

```text
SEND
destination:/queue/orders
content-type:application/json

{"orderId":"ORD-2026-0001"}
^@
```

【定理】STOMP 帧以空字符 `^@`（0x00）结束，命令、header、body 之间以换行分隔，该帧格式由 STOMP 1.2 规范定义。

主要支持 Broker：

| Broker | 支持方式 | 支持版本 |
| ------ | -------- | -------- |
| Apache ActiveMQ Classic | 内置 | 1.0 / 1.1 / 1.2 |
| Apache ActiveMQ Artemis | 内置 | 1.0 / 1.1 / 1.2 |
| RabbitMQ | 插件 `rabbitmq_stomp` | 1.0 / 1.1 / 1.2（带扩展与限制） |

STOMP 适用于：

- 脚本/命令行工具快速收发消息（如 `stomp.py`）。
- Web 浏览器通过 WebSocket + STOMP 实现实时推送（Spring WebSocket 支持 STOMP over SockJS/WebSocket）。
- 对协议复杂度敏感、但可靠性要求不极端的场景。

STOMP 的局限：

- 不支持 AMQP 1.0 的 credit-based 背压，流量控制较弱。
- 无标准化事务语义，依赖 broker 扩展。
- 二进制消息需要 Base64 等额外编码。

----

## 1.42.6 遗留系统集成选型

### 何时仍选 JMS / AMQP 1.0

| 场景特征 | 推荐标准 | 理由 |
| -------- | -------- | ---- |
| 金融 ESB、Java EE 遗留系统 | JMS 2.0 / Jakarta Messaging 3.1 | 与 Spring、EJB、应用服务器生态深度集成 |
| 跨厂商 Broker 互操作 | AMQP 1.0 | ISO/IEC 标准，Azure Service Bus、Artemis、RabbitMQ 4.0 均原生支持 |
| 需要标准化 API 但后端可能是多协议 | Qpid JMS over AMQP 1.0 | 用 JMS API 屏蔽底层 broker 差异 |
| 简单脚本/WebSocket 实时推送 | STOMP | 文本协议、接入简单、浏览器友好 |
| 云原生事件网格、函数触发 | CloudEvents / AsyncAPI | 见 [01-30-事件互操作标准分析](01-30-事件互操作标准分析.md) |

### 与现代协议对比矩阵

| 维度 | JMS/Jakarta Messaging | AMQP 1.0 | Kafka Protocol | MQTT 5.0 |
| ---- | --------------------- | -------- | -------------- | -------- |
| 本质 | Java API 规范 | 线路级协议 | 分布式日志协议 | 轻量 Pub/Sub 协议 |
| 传输中立 | 否（Java 生态） | 是 | 否（Kafka 生态） | 是 |
| 跨厂商互操作 | 依赖 API 兼容实现 | 强 | 弱 | 中（ broker 语义差异） |
| 背压机制 | 依赖实现 | Credit-based | Pull-based offset | MQTT QoS + keepalive |
| 典型吞吐 | 中（单 broker 万级 TPS） | 中高 | 高（分区横向扩展） | 中低（面向 IoT） |
| 事务 | Session 事务、XA | 事务性 settlement | 幂等生产者 + 事务 API | 无 |

【估算】上表中的“典型吞吐”为经验量级，实际数值取决于 broker 配置、网络与消息大小，建议以各自官方 benchmark 或生产压测为准。

### 迁移建议

1. **存量 JMS 应用**：若目标为 Jakarta EE 10/11，优先迁移到 `jakarta.jms`；若暂时无法迁移，可使用 Qpid JMS 1.x（`javax.jms`）对接 AMQP 1.0 broker。
2. **新建企业级消息系统**：若团队以 Java/Spring 为主且无需跨语言，Jakarta Messaging 3.1 + ActiveMQ Artemis 仍是稳妥选择；若需对接 Azure Service Bus 或多语言客户端，优先 AMQP 1.0。
3. **RabbitMQ 用户**：RabbitMQ 4.0 起 AMQP 1.0 为默认核心协议，新应用可评估直接使用官方 AMQP 1.0 Java 客户端，但 0-9-1 生态（Spring AMQP、管理插件）目前仍更广泛。

----

## 1.42.7 参考来源

- [Jakarta Messaging 3.1 规范页](https://jakarta.ee/specifications/messaging/3.1/)
- [Jakarta EE 11 Platform 规范页](https://jakarta.ee/specifications/platform/11/)
- [Payara: Differences between Jakarta EE 11 and 10](https://github.com/payara/AdvisorTool/blob/main/MIGRATION_EE10_TO_EE11.md)
- [OASIS AMQP 1.0 标准页](https://www.oasis-open.org/standard/amqp/)
- [OASIS AMQP 1.0 核心规范 PDF](https://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-complete-v1.0-os.pdf)
- [AMQP.org 资源页](https://www.amqp.org/resources/specifications/)
- [Apache ActiveMQ Classic 下载页](https://activemq.apache.org/components/classic/download/)
- [Apache ActiveMQ Artemis 下载页](https://artemis.apache.org/components/artemis/download/)
- [Apache Qpid 发布页](https://qpid.apache.org/releases/index.html)
- [RabbitMQ AMQP 1.0 文档](https://www.rabbitmq.com/docs/amqp)
- [RabbitMQ 协议支持页](https://www.rabbitmq.com/docs/protocols)
- [RabbitMQ Native AMQP 1.0 博客](https://www.rabbitmq.com/blog/2024/08/05/native-amqp)
- [RabbitMQ STOMP 插件文档](https://www.rabbitmq.com/docs/stomp)
- [STOMP 1.2 规范](https://stomp.github.io/stomp-specification-1.2.html)
- [STOMP 实现列表](https://stomp.github.io/implementations.html)
- [Spring Messaging with JMS 指南](https://spring.io/guides/gs/messaging-jms/)
- [Azure Service Bus AMQP 文档](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-amqp-overview)

----

**最后更新**: 2026-11-18
