# 代码示例库

## 目录

- [代码示例库](#代码示例库)
  - [目录](#目录)
  - [编程语言支持](#编程语言支持)
  - [RabbitMQ示例](#rabbitmq示例)
    - [Python示例](#python示例)
    - [Go示例](#go示例)
  - [Redis Stream示例](#redis-stream示例)
    - [Python示例](#python示例-1)
  - [MQTT 5.0示例](#mqtt-50示例)
    - [Python示例](#python示例-2)
  - [代码示例统计](#代码示例统计)

---

## 编程语言支持

本项目提供**5种编程语言**的完整代码示例：

- ✅ **Python** - Kafka/MQTT/NATS/Pulsar/RabbitMQ/Redis Stream
- ✅ **Go** - Kafka/MQTT/NATS/Pulsar/RabbitMQ
- ✅ **Rust** - Kafka/MQTT/NATS/Pulsar
- ✅ **C++** - Kafka/MQTT/Pulsar
- ✅ **C** - Kafka/MQTT
- ✅ **Java** - Kafka/Pulsar

**语言对比文档**: [01-编程语言对比分析](./01-编程语言对比分析.md)

---

## RabbitMQ示例

### Python示例

- **Producer**: [rabbitmq-producer-example.py](./rabbitmq-producer-example.py)
- **Consumer**: [rabbitmq-consumer-example.py](./rabbitmq-consumer-example.py)
- **依赖**: `pip install pika`
- **特点**: 简洁易用，支持Exchange-Queue模型

### Go示例

- **Producer**: [rabbitmq-producer-example.go](./rabbitmq-producer-example.go)
- **Consumer**: [rabbitmq-consumer-example.go](./rabbitmq-consumer-example.go)
- **依赖**: `go get github.com/streadway/amqp`
- **特点**: 类型安全，性能优秀

---

## Redis Stream示例

### Python示例

- **Producer**: [redis-stream-producer-example.py](./redis-stream-producer-example.py)
- **Consumer**: [redis-stream-consumer-example.py](./redis-stream-consumer-example.py)
- **依赖**: `pip install redis`
- **特点**: 轻量级流处理，低延迟

---

## MQTT 5.0示例

### Python示例

- **MQTT 5.0新特性**: [mqtt-5.0-example.py](./mqtt-5.0-example.py)
- **依赖**: `pip install paho-mqtt`
- **特点**: 演示User Properties、Shared Subscriptions等新特性

---

## 代码示例统计

| 消息队列 | Python | Go | Rust | C++ | C | Java | 总计 |
|---------|--------|----|----|-----|---|------|------|
| **Kafka** | 2 | 2 | 2 | 2 | 2 | 2 | 12 |
| **MQTT** | 2 | 1 | 1 | 1 | 1 | 0 | 6 |
| **NATS** | 1 | 1 | 1 | 0 | 0 | 0 | 3 |
| **Pulsar** | 3 | 2 | 2 | 2 | 0 | 2 | 11 |
| **RabbitMQ** | 2 | 2 | 2 | 2 | 0 | 2 | **10** |
| **Redis Stream** | 2 | 2 | 0 | 2 | 0 | 2 | **8** |
| **总计** | 12 | 12 | 8 | 9 | 3 | 10 | **54** |

**更新日期**: 2025-12-31
