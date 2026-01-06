# 快速入门指南

## 目录

- [快速入门指南](#快速入门指南)
  - [目录](#目录)
  - [5分钟快速开始](#5分钟快速开始)
    - [选择消息队列](#选择消息队列)
    - [快速部署](#快速部署)
  - [Kafka快速开始](#kafka快速开始)
    - [1. 部署Kafka](#1-部署kafka)
    - [2. 创建Topic](#2-创建topic)
    - [3. 发送消息](#3-发送消息)
    - [4. 消费消息](#4-消费消息)
    - [5. 代码示例](#5-代码示例)
  - [MQTT快速开始](#mqtt快速开始)
    - [1. 安装MQTT Broker](#1-安装mqtt-broker)
    - [2. 订阅主题](#2-订阅主题)
    - [3. 发布消息](#3-发布消息)
    - [4. 代码示例](#4-代码示例)
  - [NATS快速开始](#nats快速开始)
    - [1. 部署NATS](#1-部署nats)
    - [2. 订阅消息](#2-订阅消息)
    - [3. 发布消息](#3-发布消息-1)
    - [4. 代码示例](#4-代码示例-1)
  - [RabbitMQ快速开始](#rabbitmq快速开始)
    - [1. 部署RabbitMQ](#1-部署rabbitmq)
    - [2. 管理界面](#2-管理界面)
    - [3. 代码示例](#3-代码示例)
  - [Redis Stream快速开始](#redis-stream快速开始)
    - [1. 启动Redis](#1-启动redis)
    - [2. 添加消息](#2-添加消息)
    - [3. 读取消息](#3-读取消息)
    - [4. 代码示例](#4-代码示例-2)
  - [下一步](#下一步)

---

## 5分钟快速开始

### 选择消息队列

根据你的需求快速选择：

- **日志聚合/大数据** → Kafka
- **IoT设备通信** → MQTT
- **微服务通信** → NATS
- **任务队列** → RabbitMQ
- **轻量级流处理** → Redis Stream

### 快速部署

```bash
# Kafka
./scripts/deploy-kafka.sh

# NATS
./scripts/deploy-nats.sh

# RabbitMQ
./scripts/deploy-rabbitmq.sh
```

---

## Kafka快速开始

### 1. 部署Kafka

```bash
./scripts/deploy-kafka.sh
```

### 2. 创建Topic

```bash
kafka_*/bin/kafka-topics.sh --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

### 3. 发送消息

```bash
kafka_*/bin/kafka-console-producer.sh \
  --topic test-topic \
  --bootstrap-server localhost:9092
```

### 4. 消费消息

```bash
kafka_*/bin/kafka-console-consumer.sh \
  --topic test-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

### 5. 代码示例

参考：[examples/kafka-producer-example.py](../examples/kafka-producer-example.py)

---

## MQTT快速开始

### 1. 安装MQTT Broker

```bash
# 使用Docker
docker run -it -p 1883:1883 -p 9001:9001 eclipse-mosquitto
```

### 2. 订阅主题

```bash
mosquitto_sub -h localhost -t sensors/temperature
```

### 3. 发布消息

```bash
mosquitto_pub -h localhost -t sensors/temperature -m "25.5"
```

### 4. 代码示例

参考：[examples/mqtt-publisher-example.py](../examples/mqtt-publisher-example.py)

---

## NATS快速开始

### 1. 部署NATS

```bash
./scripts/deploy-nats.sh
```

### 2. 订阅消息

```bash
nats sub "orders.*"
```

### 3. 发布消息

```bash
nats pub "orders.created" "Order ID: 12345"
```

### 4. 代码示例

参考：[examples/nats-publisher-example.py](../examples/nats-publisher-example.py)

---

## RabbitMQ快速开始

### 1. 部署RabbitMQ

```bash
./scripts/deploy-rabbitmq.sh
```

### 2. 管理界面

访问：<http://localhost:15672>
用户名：admin，密码：admin

### 3. 代码示例

参考：[examples/rabbitmq-producer-example.py](../examples/rabbitmq-producer-example.py)

---

## Redis Stream快速开始

### 1. 启动Redis

```bash
redis-server
```

### 2. 添加消息

```bash
redis-cli XADD events:orders * order_id "ORD-001" amount "100.0"
```

### 3. 读取消息

```bash
redis-cli XREAD STREAMS events:orders 0
```

### 4. 代码示例

参考：[examples/redis-stream-producer-example.py](../examples/redis-stream-producer-example.py)

---

## 下一步

1. **深入学习**：阅读[INDEX.md](./INDEX.md)了解完整内容
2. **技术选型**：参考[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
3. **最佳实践**：查看[BEST_PRACTICES.md](./BEST_PRACTICES.md)
4. **生产部署**：参考[03-架构与运维实践](./03-架构与运维实践/)

---

**最后更新**: 2025-12-31
