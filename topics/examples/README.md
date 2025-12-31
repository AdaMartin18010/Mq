# 代码示例库

## 目录

- [代码示例库](#代码示例库)
  - [目录](#目录)
  - [编程语言支持](#编程语言支持)
  - [Kafka示例](#kafka示例)
    - [Java示例](#java示例)
    - [Python示例](#python示例)
    - [Go示例](#go示例)
    - [Rust示例](#rust示例)
    - [C++示例](#c示例)
    - [C示例](#c示例-1)
  - [MQTT示例](#mqtt示例)
    - [Python示例](#python示例-1)
    - [Go示例](#go示例-1)
    - [Rust示例](#rust示例-1)
    - [C++示例](#c示例-2)
    - [C示例](#c示例-3)
  - [NATS示例](#nats示例)
    - [Go示例（官方）](#go示例官方)
    - [Python示例](#python示例-2)
    - [Rust示例](#rust示例-2)
  - [使用说明](#使用说明)
    - [运行环境要求](#运行环境要求)
    - [快速开始](#快速开始)
    - [最佳实践](#最佳实践)
  - [代码示例统计](#代码示例统计)

---

## 编程语言支持

本项目提供**5种编程语言**的完整代码示例：

- ✅ **Python** - Kafka Producer/Consumer, MQTT Client, NATS Client
- ✅ **Go** - Kafka Producer/Consumer, MQTT Client, NATS Client
- ✅ **Rust** - Kafka Producer/Consumer, MQTT Client, NATS Client
- ✅ **C++** - Kafka Producer/Consumer, MQTT Client
- ✅ **C** - Kafka Producer/Consumer, MQTT Client
- ✅ **Java** - Kafka Producer/Consumer（已有）

**语言对比文档**: [01-编程语言对比分析](./01-编程语言对比分析.md)

---

## Kafka示例

### Java示例

- **Producer**: [kafka-producer-example.java](./kafka-producer-example.java)
- **Consumer**: [kafka-consumer-example.java](./kafka-consumer-example.java)
- **依赖**: kafka-clients (Maven/Gradle)
- **参考文档**: [01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)

### Python示例

- **Producer**: [kafka-producer-example.py](./kafka-producer-example.py)
- **Consumer**: [kafka-consumer-example.py](./kafka-consumer-example.py)
- **依赖**: `pip install kafka-python`
- **特点**: 简洁直观，开发效率高

### Go示例

- **Producer**: [kafka-producer-example.go](./kafka-producer-example.go)
- **Consumer**: [kafka-consumer-example.go](./kafka-consumer-example.go)
- **依赖**: `go get github.com/segmentio/kafka-go`
- **特点**: 类型安全，性能优秀

### Rust示例

- **Producer**: [kafka-producer-example.rs](./kafka-producer-example.rs)
- **Consumer**: [kafka-consumer-example.rs](./kafka-consumer-example.rs)
- **依赖**: `rdkafka = "0.36"` (Cargo.toml)
- **特点**: 内存安全，性能极高

### C++示例

- **Producer**: [kafka-producer-example.cpp](./kafka-producer-example.cpp)
- **Consumer**: [kafka-consumer-example.cpp](./kafka-consumer-example.cpp)
- **依赖**: librdkafka (<https://github.com/edenhill/librdkafka>)
- **特点**: 性能极高，控制精细

### C示例

- **Producer**: [kafka-producer-example.c](./kafka-producer-example.c)
- **Consumer**: [kafka-consumer-example.c](./kafka-consumer-example.c)
- **依赖**: librdkafka
- **特点**: 最底层控制，性能最高

## MQTT示例

### Python示例

- **Client**: [mqtt-client-example.py](./mqtt-client-example.py)
- **依赖**: `pip install paho-mqtt`
- **特点**: 简洁易用，适合快速开发

### Go示例

- **Client**: [mqtt-client-example.go](./mqtt-client-example.go)
- **依赖**: `go get github.com/eclipse/paho.mqtt.golang`
- **特点**: 类型安全，并发友好

### Rust示例

- **Client**: [mqtt-client-example.rs](./mqtt-client-example.rs)
- **依赖**: `paho-mqtt = "0.12"` (Cargo.toml)
- **特点**: 内存安全，性能优秀

### C++示例

- **Client**: [mqtt-client-example.cpp](./mqtt-client-example.cpp)
- **依赖**: paho.mqtt.cpp (<https://github.com/eclipse/paho.mqtt.cpp>)
- **特点**: 性能优秀，面向对象

### C示例

- **Client**: [mqtt-client-example.c](./mqtt-client-example.c)
- **依赖**: paho.mqtt.c (<https://github.com/eclipse/paho.mqtt.c>)
- **特点**: 最底层控制，性能最高

## NATS示例

### Go示例（官方）

- **Client**: [nats-client-example.go](./nats-client-example.go)
- **依赖**: `go get github.com/nats-io/nats.go`
- **特点**: 官方支持，性能最优

### Python示例

- **Client**: [nats-client-example.py](./nats-client-example.py)
- **依赖**: `pip install nats-py`
- **特点**: 异步支持，简洁易用

### Rust示例

- **Client**: [nats-client-example.rs](./nats-client-example.rs)
- **依赖**: `async-nats = "0.32"` (Cargo.toml)
- **特点**: 内存安全，性能极高

## Pulsar示例

### Java示例

- **Producer**: [pulsar-producer-example.java](./pulsar-producer-example.java)
- **Consumer**: [pulsar-consumer-example.java](./pulsar-consumer-example.java)
- **依赖**: `pulsar-client` (Maven/Gradle)
- **特点**: 官方支持，功能完整，支持事务和多订阅模式

### Python示例

- **Producer**: [pulsar-producer-example.py](./pulsar-producer-example.py)
- **Consumer**: [pulsar-consumer-example.py](./pulsar-consumer-example.py)
- **Producer容错**: [pulsar-producer-error-handling.py](./pulsar-producer-error-handling.py)
- **依赖**: `pip install pulsar-client`
- **特点**: 简洁易用，支持异步发送和多种订阅模式，包含完整的容错异常处理

### Go示例

- **Producer容错**: [pulsar-producer-error-handling.go](./pulsar-producer-error-handling.go)
- **Consumer容错**: [pulsar-consumer-error-handling.go](./pulsar-consumer-error-handling.go)
- **依赖**: `go get github.com/apache/pulsar-client-go/pulsar`
- **特点**: 纯Go实现，无CGO依赖，包含完整的重试机制、死信队列、错误处理

### Rust示例

- **Producer容错**: [pulsar-producer-error-handling.rs](./pulsar-producer-error-handling.rs)
- **Consumer容错**: [pulsar-consumer-error-handling.rs](./pulsar-consumer-error-handling.rs)
- **依赖**: `pulsar-client = "0.1"` (Cargo.toml)
- **特点**: 内存安全，性能极高，包含指数退避重试、错误分类处理

### C++示例

- **Producer容错**: [pulsar-producer-error-handling.cpp](./pulsar-producer-error-handling.cpp)
- **Consumer容错**: [pulsar-consumer-error-handling.cpp](./pulsar-consumer-error-handling.cpp)
- **依赖**: pulsar-client-cpp (<https://github.com/apache/pulsar-client-cpp>)
- **特点**: 性能极高，控制精细，包含完整的异步回调和错误处理机制

**容错特性**（基于concept06.md）：

- ✅ **自动重连机制**：多Broker故障转移
- ✅ **指数退避重试**：可配置的重试策略
- ✅ **死信队列支持**：自动处理失败消息
- ✅ **错误分类处理**：区分可重试和不可重试错误
- ✅ **连接状态监听**：实时监控连接健康状态

## 使用说明

### 运行环境要求

**Python**:

- Python 3.6+
- Kafka: `pip install kafka-python`
- MQTT: `pip install paho-mqtt`
- NATS: `pip install nats-py`
- Pulsar: `pip install pulsar-client`

**Go**:

- Go 1.16+
- Kafka: `go get github.com/segmentio/kafka-go`
- MQTT: `go get github.com/eclipse/paho.mqtt.golang`
- NATS: `go get github.com/nats-io/nats.go`
- Pulsar: `go get github.com/apache/pulsar-client-go`

**Rust**:

- Rust 1.56+
- Kafka: `rdkafka = "0.36"` (Cargo.toml)
- MQTT: `paho-mqtt = "0.12"` (Cargo.toml)
- NATS: `async-nats = "0.32"` (Cargo.toml)
- Pulsar: `pulsar-client = "0.1"` (Cargo.toml)

**C++**:

- C++11+
- Kafka: librdkafka (<https://github.com/edenhill/librdkafka>)
- MQTT: paho.mqtt.cpp (<https://github.com/eclipse/paho.mqtt.cpp>)
- Pulsar: pulsar-client-cpp (<https://github.com/apache/pulsar-client-cpp>)

**C**:

- C99+
- Kafka: librdkafka
- MQTT: paho.mqtt.c (<https://github.com/eclipse/paho.mqtt.c>)

**Java**:

- Java 8+
- Kafka: kafka-clients (Maven/Gradle)
- Pulsar: pulsar-client (Maven/Gradle)

### 快速开始

1. **准备环境**: 确保相应的消息队列服务已启动
2. **安装依赖**: 安装所需的客户端库
3. **运行示例**: 根据示例代码修改配置后运行
4. **参考文档**: 查看相关主题文档了解详细原理

### 最佳实践

1. **错误处理**: 所有示例都包含基本的错误处理
2. **资源清理**: 正确关闭连接和释放资源
3. **配置优化**: 根据实际场景调整配置参数
4. **监控告警**: 在生产环境中添加监控和告警

---

---

## 代码示例统计

| 消息队列 | Python | Go | Rust | C++ | C | Java | 总计 |
|---------|--------|----|----|-----|---|------|------|
| **Kafka** | 2 | 2 | 2 | 2 | 2 | 2 | 12 |
| **MQTT** | 1 | 1 | 1 | 1 | 1 | 0 | 5 |
| **NATS** | 1 | 1 | 1 | 0 | 0 | 0 | 3 |
| **Pulsar** | 3 | 2 | 2 | 2 | 0 | 2 | **11** |
| **总计** | 7 | 6 | 6 | 5 | 3 | 4 | **31** |

**文档**: [编程语言对比分析](./01-编程语言对比分析.md)

**更新日期**: 2025-12-31
