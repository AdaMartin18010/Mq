# 1.15 RabbitMQ深度分析

## 目录

- [1.15 RabbitMQ深度分析](#115-rabbitmq深度分析)
  - [目录](#目录)
  - [1.15.1 RabbitMQ核心架构](#1151-rabbitmq核心架构)
    - [AMQP协议基础](#amqp协议基础)
    - [RabbitMQ架构组件](#rabbitmq架构组件)
    - [消息流转机制](#消息流转机制)
  - [1.15.2 RabbitMQ核心概念](#1152-rabbitmq核心概念)
    - [Exchange（交换机）](#exchange交换机)
    - [Queue（队列）](#queue队列)
    - [Binding（绑定）](#binding绑定)
    - [Routing Key（路由键）](#routing-key路由键)
  - [1.15.3 RabbitMQ消息模型](#1153-rabbitmq消息模型)
    - [Direct Exchange](#direct-exchange)
    - [Topic Exchange](#topic-exchange)
    - [Fanout Exchange](#fanout-exchange)
    - [Headers Exchange](#headers-exchange)
  - [1.15.4 RabbitMQ性能特性](#1154-rabbitmq性能特性)
    - [吞吐量性能](#吞吐量性能)
    - [延迟特性](#延迟特性)
    - [可靠性保证](#可靠性保证)
  - [1.15.5 RabbitMQ与Kafka/NATS/MQTT对比](#1155-rabbitmq与kafkanatsmqtt对比)
    - [架构对比](#架构对比)
    - [性能对比](#性能对比)
    - [适用场景对比](#适用场景对比)
  - [1.15.6 RabbitMQ应用场景](#1156-rabbitmq应用场景)
    - [任务队列](#任务队列)
    - [微服务通信](#微服务通信)
    - [事件驱动架构](#事件驱动架构)
    - [工作流编排](#工作流编排)
  - [1.15.7 RabbitMQ最佳实践](#1157-rabbitmq最佳实践)
    - [Exchange设计](#exchange设计)
    - [Queue管理](#queue管理)
    - [消息确认机制](#消息确认机制)
    - [集群配置](#集群配置)
  - [1.15.8 RabbitMQ参考资源](#1158-rabbitmq参考资源)
    - [官方文档](#官方文档)
    - [技术博客](#技术博客)
    - [生产案例](#生产案例)
  - [1.15.9 RabbitMQ 4.x 演进](#1159-rabbitmq-4x-演进)
    - [版本时间线](#版本时间线)
    - [4.0 关键变化](#40-关键变化)
    - [升级注意事项](#升级注意事项)
    - [参考来源](#参考来源)

---

## 1.15.1 RabbitMQ核心架构

### AMQP协议基础

**AMQP（Advanced Message Queuing Protocol）**是RabbitMQ的核心协议，是一个开放标准的消息中间件协议。

**AMQP协议特点**：

- ✅ **标准化**：OASIS标准，多语言支持
- ✅ **可靠性**：支持消息确认、持久化、事务
- ✅ **路由灵活**：支持多种Exchange类型
- ✅ **企业级**：支持集群、高可用、负载均衡

**AMQP协议版本**：

| 版本 | 说明 | RabbitMQ支持 |
| ------ | ------ | ------------- |
| **AMQP 0-9-1** | 最广泛使用 | ✅ 完全支持 |
| **AMQP 1.0** | 新标准 | ✅ 支持（插件） |
| **AMQP 0-8** | 旧版本 | ⚠️ 已弃用 |

**参考**: [AMQP 0-9-1 Specification](https://www.rabbitmq.com/amqp-0-9-1-reference.html)

### RabbitMQ架构组件

**RabbitMQ架构图**：

```text
┌─────────────────────────────────────────────────────────┐
│              RabbitMQ集群架构                             │
└─────────────────────────────────────────────────────────┘

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  RabbitMQ Node-1 │  │  RabbitMQ Node-2 │  │  RabbitMQ Node-3 │
│  (Disk Node)     │  │  (RAM Node)      │  │  (Disk Node)     │
│                  │  │                  │  │                  │
│  ┌────────────┐ │  │  ┌────────────┐ │  │  ┌────────────┐ │
│  │ Exchange   │ │  │  │ Exchange   │ │  │  │ Exchange   │ │
│  │ (交换机)    │ │  │  │ (交换机)    │ │  │  │ (交换机)    │ │
│  └─────┬──────┘ │  │  └─────┬──────┘ │  │  └─────┬──────┘ │
│        │        │  │        │        │  │        │        │
│        ↓        │  │        ↓        │  │        ↓        │
│  ┌────────────┐ │  │  ┌────────────┐ │  │  ┌────────────┐ │
│  │ Queue      │ │  │  │ Queue      │ │  │  │ Queue      │ │
│  │ (队列)      │ │  │  │ (队列)      │ │  │  │ (队列)      │ │
│  └────────────┘ │  │  └────────────┘ │  │  └────────────┘ │
│                  │  │                  │  │                  │
│  ┌────────────┐ │  │  ┌────────────┐ │  │  ┌────────────┐ │
│  │ Mnesia DB  │ │  │  │ Mnesia DB  │ │  │  │ Mnesia DB  │ │
│  │ (元数据)    │ │  │  │ (元数据)    │ │  │  │ (元数据)    │ │
│  └────────────┘ │  │  └────────────┘ │  │  └────────────┘ │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │   Erlang Cluster     │
                    │   (集群通信)          │
                    └──────────────────────┘
```

**核心组件**：

1. **Exchange（交换机）**：接收消息，根据路由规则转发到队列
2. **Queue（队列）**：存储消息，等待消费者消费
3. **Binding（绑定）**：连接Exchange和Queue的规则
4. **Producer（生产者）**：发送消息到Exchange
5. **Consumer（消费者）**：从Queue消费消息

### 消息流转机制

**消息流转流程**：

```text
1. Producer发送消息
   ↓
2. 消息到达Exchange
   ↓
3. Exchange根据Routing Key和Binding规则路由
   ↓
4. 消息被路由到匹配的Queue
   ↓
5. Queue存储消息（持久化或内存）
   ↓
6. Consumer从Queue消费消息
   ↓
7. Consumer发送ACK确认
   ↓
8. Queue删除已确认的消息
```

**参考**: [RabbitMQ Architecture](https://www.rabbitmq.com/tutorials/amqp-concepts.html)

---

## 1.15.2 RabbitMQ核心概念

### Exchange（交换机）

**Exchange类型**：

| Exchange类型 | 路由规则 | 使用场景 |
| ------------- | --------- | --------- |
| **Direct** | 精确匹配Routing Key | 点对点消息 |
| **Topic** | 模式匹配Routing Key | 主题订阅 |
| **Fanout** | 忽略Routing Key，广播 | 广播消息 |
| **Headers** | 匹配消息Headers | 复杂路由规则 |

**Exchange属性**：

- **Name**：Exchange名称
- **Type**：Exchange类型（direct/topic/fanout/headers）
- **Durability**：是否持久化
- **Auto-delete**：无绑定队列时自动删除

### Queue（队列）

**Queue属性**：

- **Name**：队列名称（可自动生成）
- **Durability**：是否持久化
- **Exclusive**：是否排他（仅当前连接可用）
- **Auto-delete**：无消费者时自动删除
- **Arguments**：额外参数（TTL、最大长度等）

**Queue声明示例**（Python）：

```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()

# 声明持久化队列
channel.queue_declare(
    queue='task_queue',
    durable=True  # 队列持久化
)
```

### Binding（绑定）

**Binding规则**：

- **Exchange**：绑定的Exchange
- **Queue**：绑定的Queue
- **Routing Key**：路由键（用于匹配）
- **Arguments**：额外参数（Headers Exchange使用）

**Binding示例**：

```python
# Direct Exchange绑定
channel.queue_bind(
    exchange='direct_exchange',
    queue='task_queue',
    routing_key='task'
)

# Topic Exchange绑定（支持通配符）
channel.queue_bind(
    exchange='topic_exchange',
    queue='logs_queue',
    routing_key='logs.*'  # 匹配logs.info, logs.error等
)
```

### Routing Key（路由键）

**Routing Key规则**：

- **Direct Exchange**：精确匹配
  - `routing_key='task'` → 匹配 `routing_key='task'`
- **Topic Exchange**：模式匹配
  - `routing_key='logs.*'` → 匹配 `logs.info`, `logs.error`
  - `routing_key='logs.#'` → 匹配 `logs.info`, `logs.error.debug`
- **Fanout Exchange**：忽略Routing Key
- **Headers Exchange**：忽略Routing Key，匹配Headers

---

## 1.15.3 RabbitMQ消息模型

### Direct Exchange

**Direct Exchange**：精确匹配Routing Key，实现点对点消息传递。

**使用场景**：

- 任务队列
- 点对点通信
- 精确路由

**示例**：

```python
# Producer
channel.exchange_declare(exchange='direct_exchange', exchange_type='direct')
channel.basic_publish(
    exchange='direct_exchange',
    routing_key='task',
    body='Task message'
)

# Consumer
channel.queue_bind(
    exchange='direct_exchange',
    queue='task_queue',
    routing_key='task'
)
```

### Topic Exchange

**Topic Exchange**：模式匹配Routing Key，实现主题订阅。

**通配符规则**：

- `*`：匹配一个单词
- `#`：匹配零个或多个单词

**示例**：

```python
# Routing Key: logs.info, logs.error, logs.debug
# Binding: logs.* → 匹配所有logs开头的消息

channel.exchange_declare(exchange='topic_exchange', exchange_type='topic')
channel.queue_bind(
    exchange='topic_exchange',
    queue='logs_queue',
    routing_key='logs.*'  # 匹配logs.info, logs.error等
)
```

### Fanout Exchange

**Fanout Exchange**：忽略Routing Key，广播到所有绑定的队列。

**使用场景**：

- 广播消息
- 事件通知
- 日志分发

**示例**：

```python
# Producer
channel.exchange_declare(exchange='fanout_exchange', exchange_type='fanout')
channel.basic_publish(
    exchange='fanout_exchange',
    routing_key='',  # 忽略
    body='Broadcast message'
)

# Consumer（多个队列都会收到消息）
channel.queue_bind(exchange='fanout_exchange', queue='queue1')
channel.queue_bind(exchange='fanout_exchange', queue='queue2')
```

### Headers Exchange

**Headers Exchange**：忽略Routing Key，根据消息Headers匹配。

**匹配规则**：

- `x-match: all`：所有Headers必须匹配
- `x-match: any`：任意Header匹配即可

**示例**：

```python
# Binding
channel.queue_bind(
    exchange='headers_exchange',
    queue='queue1',
    arguments={
        'x-match': 'all',
        'type': 'order',
        'priority': 'high'
    }
)

# Producer
channel.basic_publish(
    exchange='headers_exchange',
    routing_key='',
    body='Message',
    properties=pika.BasicProperties(
        headers={'type': 'order', 'priority': 'high'}
    )
)
```

---

## 1.15.4 RabbitMQ性能特性

### 吞吐量性能

**性能指标**（基于官方基准测试）：

| 场景 | 吞吐量 | 说明 |
| ------ | -------- | ------ |
| **单队列单消费者** | 10,000-50,000 msg/s | 取决于消息大小 |
| **多队列多消费者** | 50,000-200,000 msg/s | 水平扩展 |
| **持久化消息** | 5,000-20,000 msg/s | 磁盘写入限制 |
| **非持久化消息** | 50,000-200,000 msg/s | 内存操作 |

**性能优化**：

- ✅ **消息批量确认**：减少ACK次数
- ✅ **预取数量**：合理设置prefetch_count
- ✅ **持久化策略**：按需选择持久化
- ✅ **集群模式**：水平扩展提升吞吐量

**参考**: [RabbitMQ Performance](https://www.rabbitmq.com/performance.html)

### 延迟特性

**延迟指标**：

| 场景 | 延迟 | 说明 |
| ------ | ------ | ------ |
| **内存队列** | < 1ms | 非持久化消息 |
| **持久化队列** | 1-10ms | 磁盘写入延迟 |
| **集群模式** | 5-20ms | 网络延迟 |

### 可靠性保证

**可靠性机制**：

1. **消息确认（ACK）**：
   - **自动确认**：消息发送后立即确认
   - **手动确认**：消费者处理完成后确认
   - **NACK**：拒绝消息，可重新入队

2. **消息持久化**：
   - **Exchange持久化**：`durable=True`
   - **Queue持久化**：`durable=True`
   - **消息持久化**：`delivery_mode=2`

3. **事务支持**：
   - **事务模式**：保证消息原子性
   - **发布确认**：异步确认机制（性能更好）

**可靠性配置示例**：

```python
# 声明持久化Exchange和Queue
channel.exchange_declare(exchange='exchange', exchange_type='direct', durable=True)
channel.queue_declare(queue='queue', durable=True)

# 发送持久化消息
channel.basic_publish(
    exchange='exchange',
    routing_key='key',
    body='Message',
    properties=pika.BasicProperties(
        delivery_mode=2  # 持久化消息
    )
)

# 手动确认
def callback(ch, method, properties, body):
    # 处理消息
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(queue='queue', on_message_callback=callback)
```

---

## 1.15.5 RabbitMQ与Kafka/NATS/MQTT对比

### 架构对比

| 维度 | RabbitMQ | Kafka | NATS | MQTT |
| ------ | ---------- | ------- | ------ | ------ |
| **协议** | AMQP 0-9-1 | 自定义二进制 | NATS文本协议 | MQTT 3.1.1/5.0 |
| **消息模型** | Exchange-Queue | Topic-Partition | Subject | Topic |
| **路由方式** | Exchange路由 | 分区路由 | 主题匹配 | 主题匹配 |
| **存储** | 内存/磁盘 | 磁盘顺序写 | 内存（Core） | 内存/可选持久化 |
| **集群模式** | Erlang集群 | Leader-Follower | 全网状 | 主从/集群 |

### 性能对比

| 指标 | RabbitMQ | Kafka | NATS Core | MQTT |
| ------ | ---------- | ------- | ----------- | ------ |
| **吞吐量** | 5-20万 TPS | 100万+ TPS | 200万+ TPS | 10万级 TPS |
| **延迟** | 1-10ms | 5-100ms | 30-100μs | 亚毫秒-10ms |
| **持久化** | ✅ 支持 | ✅ 强持久化 | ❌ Core无 | ⚠️ 可选 |
| **顺序性** | ⚠️ 单队列有序 | ✅ 分区有序 | ❌ 无序 | ❌ 无序 |

### 适用场景对比

| 场景 | RabbitMQ | Kafka | NATS | MQTT |
| ------ | ---------- | ------- | ------ | ------ |
| **任务队列** | ✅ 优秀 | ⚠️ 不适用 | ⚠️ 不适用 | ❌ 不适用 |
| **微服务通信** | ✅ 优秀 | ⚠️ 过度设计 | ✅ 优秀 | ⚠️ 协议重 |
| **事件流处理** | ⚠️ 有限 | ✅ 优秀 | ⚠️ 有限 | ❌ 不适用 |
| **日志聚合** | ❌ 不适用 | ✅ 优秀 | ❌ 不适用 | ❌ 不适用 |
| **IoT设备** | ❌ 不适用 | ❌ 不适用 | ⚠️ 有限 | ✅ 优秀 |
| **工作流编排** | ✅ 优秀 | ❌ 不适用 | ⚠️ 有限 | ❌ 不适用 |

**选型建议**：

- **任务队列/工作流** → ✅ RabbitMQ
- **事件流/日志聚合** → ✅ Kafka
- **微服务通信** → ✅ RabbitMQ或NATS
- **IoT设备** → ✅ MQTT

---

## 1.15.6 RabbitMQ应用场景

### 任务队列

**场景描述**：异步任务处理，如邮件发送、图片处理等。

**架构设计**：

```text
Web应用
   ↓
RabbitMQ (Task Queue)
   ↓
Worker进程（多个）
   ├── Worker-1: 处理邮件
   ├── Worker-2: 处理图片
   └── Worker-3: 处理数据
```

**实现示例**：

```python
# Producer
channel.queue_declare(queue='task_queue', durable=True)
channel.basic_publish(
    exchange='',
    routing_key='task_queue',
    body='Task data',
    properties=pika.BasicProperties(delivery_mode=2)
)

# Consumer
def callback(ch, method, properties, body):
    # 处理任务
    process_task(body)
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_qos(prefetch_count=1)  # 公平分发
channel.basic_consume(queue='task_queue', on_message_callback=callback)
```

### 微服务通信

**场景描述**：微服务间异步消息通信。

**架构设计**：

```text
服务A → Topic Exchange → 服务B
                      → 服务C
                      → 服务D
```

**实现示例**：

```python
# 服务A（Producer）
channel.exchange_declare(exchange='service_events', exchange_type='topic')
channel.basic_publish(
    exchange='service_events',
    routing_key='order.created',
    body='Order data'
)

# 服务B（Consumer）
channel.queue_bind(
    exchange='service_events',
    queue='service_b_queue',
    routing_key='order.*'
)
```

### 事件驱动架构

**场景描述**：基于事件的系统架构，解耦服务依赖。

**架构设计**：

```text
订单服务 → Fanout Exchange → 库存服务
                            → 支付服务
                            → 通知服务
```

### 工作流编排

**场景描述**：复杂业务流程的异步编排。

**架构设计**：

```text
步骤1 → Queue1 → Worker1
                ↓
步骤2 → Queue2 → Worker2
                ↓
步骤3 → Queue3 → Worker3
```

---

## 1.15.7 RabbitMQ最佳实践

### Exchange设计

**Exchange设计原则**：

- ✅ **按业务域划分**：不同业务使用不同Exchange
- ✅ **合理选择类型**：根据路由需求选择Exchange类型
- ✅ **持久化配置**：生产环境Exchange必须持久化
- ✅ **命名规范**：使用清晰的命名规范

**示例**：

```python
# 订单业务Exchange
channel.exchange_declare(
    exchange='order.exchange',
    exchange_type='topic',
    durable=True
)

# 用户业务Exchange
channel.exchange_declare(
    exchange='user.exchange',
    exchange_type='direct',
    durable=True
)
```

### Queue管理

**Queue管理原则**：

- ✅ **持久化队列**：生产环境队列必须持久化
- ✅ **设置TTL**：避免消息堆积
- ✅ **设置最大长度**：防止内存溢出
- ✅ **死信队列**：处理失败消息

**示例**：

```python
# 声明队列，设置TTL和最大长度
channel.queue_declare(
    queue='task_queue',
    durable=True,
    arguments={
        'x-message-ttl': 3600000,  # 1小时TTL
        'x-max-length': 10000,     # 最大10000条消息
        'x-dead-letter-exchange': 'dlx'  # 死信Exchange
    }
)
```

### 消息确认机制

**确认机制选择**：

- ✅ **手动确认**：生产环境必须使用手动确认
- ✅ **批量确认**：提升性能
- ✅ **NACK处理**：合理处理失败消息

**示例**：

```python
# 手动确认
def callback(ch, method, properties, body):
    try:
        process_message(body)
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as e:
        # 处理失败，重新入队
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

# 设置预取数量（公平分发）
channel.basic_qos(prefetch_count=1)
channel.basic_consume(queue='queue', on_message_callback=callback)
```

### 集群配置

**集群模式配置**：

- ✅ **磁盘节点**：至少2个磁盘节点保证元数据持久化
- ✅ **镜像队列**：配置队列镜像保证高可用
- ✅ **负载均衡**：使用HAProxy或负载均衡器

**镜像队列配置**：

```bash
# 设置队列镜像策略
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'

# 设置队列镜像到指定节点
rabbitmqctl set_policy ha-nodes "^" '{"ha-mode":"nodes","ha-params":["node1","node2"]}'
```

---

## 1.15.8 RabbitMQ参考资源

### 官方文档

- [RabbitMQ官方文档](https://www.rabbitmq.com/documentation.html)
- [AMQP 0-9-1规范](https://www.rabbitmq.com/amqp-0-9-1-reference.html)
- [RabbitMQ教程](https://www.rabbitmq.com/getstarted.html)
- [RabbitMQ性能指南](https://www.rabbitmq.com/performance.html)

### 技术博客

- [RabbitMQ Best Practices](https://www.rabbitmq.com/best-practices.html)
- [RabbitMQ Clustering Guide](https://www.rabbitmq.com/clustering.html)

### 生产案例

- **GitHub**: 使用RabbitMQ处理异步任务
- **Atlassian**: 使用RabbitMQ实现微服务通信
- **NASA**: 使用RabbitMQ处理任务队列

---

## 1.15.9 RabbitMQ 4.x 演进

### 版本时间线

| 版本 | 发布时间 | 主要定位 |
| ------ | ---------- | ---------- |
| **RabbitMQ 3.13.x** | 2024 年 | 最后一个支持 classic queue mirroring 的主版本；Khepri 元数据存储可选 |
| **RabbitMQ 4.0** | 2024-09-18 | 重大主版本，移除 classic queue mirroring，quorum queues 成为唯一可复制队列类型 |
| **RabbitMQ 4.1** | 2025 年 | AMQP filter expressions、更快的 quorum queues、rabbitmqadmin v2 |
| **RabbitMQ 4.2** | 2025 年 | 新集群默认使用 Khepri、SQL stream filters |
| **RabbitMQ 4.3** | 2026 年 | 完全移除 Mnesia，quorum queue 延迟重试与消费者超时 |

### 4.0 关键变化

1. **Classic Queue Mirroring 彻底移除**
   - 自 4.0 起，classic queues 不再支持镜像复制，仅保留单副本。
   - Quorum queues 与 streams 成为高可用、可复制数据的唯一选择。
   - 官方建议仍在使用 mirrored classic queues 的用户在升级到 4.0 前迁移到 quorum queues。

2. **Quorum Queues 成为默认高可用方案**
   - 基于 Raft 共识协议，提供比 classic mirrored queues 更高的数据安全性。
   - 4.0 为 quorum queues 引入消息优先级（初始为两级：normal/high）。
   - Single Active Consumer 与消费者优先级结合：高优先级消费者可抢占当前 active consumer。
   - 默认 `delivery-limit` 从“无限重试”改为 **20**，未配置死信队列时超过 20 次投递的消息将被丢弃。

3. **Khepri 元数据存储转正**
   - Khepri 是 RabbitMQ 自研的 Raft-based 元数据存储，用于替代 Erlang Mnesia。
   - 4.0 中 Khepri 已 fully supported，可解决 Mnesia 在 split-brain 场景下恢复困难的问题。

4. **AMQP 1.0 成为核心协议**
   - AMQP 1.0 插件变为始终启用，无需单独安装。
   - 在部分工作负载下，AMQP 1.0 峰值吞吐较 3.13.x 提升超过一倍。
   - AMQP 1.0 客户端现在可以像 AMQP 0-9-1 客户端一样管理拓扑。

5. **Streams 插件持续增强**
   - Streams 提供类 Kafka 的追加日志语义，支持百万级 msg/s 吞吐。
   - 4.x 系列继续增强过滤、消费与监控能力。

6. **队列恢复性能提升**
   - Quorum queues 引入 checkpoint 文件，节点重启时无需回放完整 Raft log，长队列启动时间从数十秒降至毫秒级。

### 升级注意事项

- **必须先迁移 mirrored classic queues**：在 3.13.x 中使用官方迁移工具或策略将镜像 classic queues 转为 quorum queues，否则 4.0 启动会报错。
- **检查 delivery-limit 默认值**：如果业务依赖消息无限重试，需显式设置 `x-delivery-limit` 或配置死信队列（DLX）。
- **启用所有 feature flags**：升级前需启用所有 feature flags，否则无法滚动升级。
- **Erlang/OTP 版本要求**：4.0 需要 Erlang 26.2 或更高版本。
- **默认最大消息大小调整**：4.0 默认最大消息大小有所降低，发送大消息需评估并调整配置。
- **生产环境建议**：先在测试环境完成滚动升级与队列类型迁移验证，再切换生产集群。

### 参考来源

- [RabbitMQ 4.0: New Quorum Queue Features](https://www.rabbitmq.com/blog/2024/08/28/quorum-queues-in-4.0)
- [RabbitMQ Quorum Queues 官方文档](https://www.rabbitmq.com/docs/quorum-queues)
- [Migrate Mirrored Classic Queues to Quorum Queues](https://www.rabbitmq.com/docs/3.13/migrate-mcq-to-qq)
- [RabbitMQ 4.0.0 Release Notes (GitHub)](https://github.com/rabbitmq/rabbitmq-server/releases)

---

**最后更新**: 2026-01-06
**适用版本**: RabbitMQ 3.8.0+ / 4.x 系列
