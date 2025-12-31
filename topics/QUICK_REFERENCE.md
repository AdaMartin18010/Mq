# 消息队列快速参考卡片

> **数据来源**: 基于官方文档、基准测试和生产环境实际数据整理
>
> - Kafka: LinkedIn Engineering Blog, Confluent官方基准测试
> - MQTT: OASIS标准规范, EMQX官方基准测试
> - NATS: CNCF官方文档, NATS官方性能基准

## 🚀 技术选型快速决策

### 场景 → 技术映射

| 场景 | 首选 | 关键指标 | 备选 |
|------|------|----------|------|
| **日志聚合** | Kafka | 100万+ TPS, 持久化 | Pulsar |
| **IoT设备** | MQTT | 2字节头, QoS分级 | NATS+桥接 |
| **微服务通信** | NATS | 30-100μs延迟 | gRPC+Kafka |
| **事件溯源** | Kafka | 不可变日志, 重放 | JetStream |
| **边缘计算** | NATS Core | <20MB二进制 | NanoMQ |
| **金融交易** | Kafka+事务 | 精确一次, 顺序 | RabbitMQ |

### 性能指标速查

| 指标 | Kafka | MQTT | NATS Core | NATS JetStream | Pulsar |
|------|-------|------|-----------|----------------|--------|
| **吞吐量** | 100万+ TPS<br/>*LinkedIn: 2M+ TPS* | 10万级 TPS<br/>*EMQX: 100K+ TPS* | 200万+ TPS<br/>*官方: 500K+ TPS/核* | 50万+ TPS<br/>*JetStream持久化* | 100万+ TPS<br/>*官方: 1.5M+ msg/s* |
| **延迟** | 5-100ms<br/>*P99: <10ms* | 亚毫秒-10ms<br/>*QoS 0: <1ms* | 30-100μs<br/>*P99: <100μs* | 亚毫秒-毫秒<br/>*P99: <1ms* | 5-50ms<br/>*P99: <20ms* |
| **持久化** | ✅ 磁盘+副本 | ⚠️ 可选 | ❌ 无 | ✅ 文件+Raft | ✅ BookKeeper |
| **一致性** | ✅ 强一致(ISR) | ⚠️ QoS分级 | ❌ 最多一次 | ✅ 强一致(Raft) | ✅ 强一致(Quorum) |

## 📊 核心参数对比

### 消息模型

- **Kafka**: 发布-订阅 + 队列（Consumer Group）
- **MQTT**: 发布-订阅（Topic）
- **NATS Core**: 发布-订阅 + 请求-响应
- **NATS JetStream**: 发布-订阅 + 流
- **Pulsar**: 发布-订阅 + 队列（多种订阅模式）

### 协议特性

- **Kafka**: 自定义二进制协议
- **MQTT**: OASIS标准（3.1.1/5.0），2字节固定头
- **NATS**: 文本协议，简单易调试
- **Pulsar**: 自定义二进制协议 + 多协议适配器（Kafka/MQTT/AMQP）

### 集群模式

- **Kafka**: Leader-Follower + ZooKeeper
- **MQTT**: 主从/集群（共享存储）
- **NATS**: 全网状自愈（Gossip协议）
- **Pulsar**: Broker无状态 + BookKeeper集群（存储与计算分离）

## 🎯 选型决策树（简化版）

```text
需要持久化？
├─ 是 → 吞吐量 > 100万TPS?
│   ├─ 是 → Kafka
│   └─ 否 → NATS JetStream
└─ 否 → 延迟要求 < 1ms?
    ├─ 是 → NATS Core
    └─ 否 → IoT设备?
        ├─ 是 → MQTT
        └─ 否 → NATS Core
```

## 💰 成本对比（TCO）

| 成本项 | Kafka | MQTT | NATS Core | Pulsar |
|--------|-------|------|-----------|--------|
| **基础设施** | 高 (3×8核32GB) | 中 (2×4核16GB) | 极低 (1×2核4GB) | 高 (3 Broker+3 BookKeeper+3 ZK) |
| **人力成本** | 高 (需专家) | 中 (协议理解) | 极低 (1人可运维) | 中高 (需BookKeeper运维经验) |
| **运维复杂度** | 高 (200+参数) | 中 (50+参数) | 低 (<20参数) | 高 (多组件配置，但动态配置降低复杂度) |

## 🔧 部署复杂度

| 维度 | Kafka | MQTT | NATS Core | Pulsar |
|------|-------|------|-----------|--------|
| **最少节点** | 6 (3 Broker+3 ZK) | 2 | 1 | 9 (3 Broker+3 BookKeeper+3 ZK) |
| **外部依赖** | ZooKeeper | 共享存储 | 无 | ZooKeeper（或Etcd） |
| **配置复杂度** | 高 | 中 | 低 | 高（但支持动态配置） |
| **启动时间** | 分钟级 | 秒级 | 秒级 | 分钟级（Broker无状态，启动快） |

## 📈 监控关键指标

### Kafka黄金指标

- UnderReplicatedPartitions（欠副本分区）
- ConsumerLag（消费延迟）
- ISRShrinkRate（ISR收缩速率）

### MQTT黄金指标

- ConnectedClients（连接数）
- MessageDropRate（消息丢弃率）
- KeepAliveTimeout（心跳超时率）

### NATS黄金指标

- Routes（集群路由数）
- SlowConsumers（慢消费者）
- MemoryUsage（内存占用）

### Pulsar黄金指标

- ConsumerLag（消费延迟）
- Backlog（消息积压）
- BookKeeper健康状态
- Broker连接数

## 🚨 故障恢复时间（RTO）

| 故障类型 | Kafka | MQTT | NATS Core | Pulsar |
|----------|-------|------|-----------|--------|
| **节点宕机** | 30秒-2分钟 | 1-3分钟 | 0-5秒 | 2秒-1分钟（Broker无状态） |
| **网络分区** | 5-30分钟 | 需人工 | 秒级自动 | 秒级自动（BookKeeper Quorum） |
| **配置错误** | 需重启 | 主从切换 | 热加载 | 热加载（动态配置） |

## 🎓 学习曲线

| 技术 | 学习时间 | 关键技能 | 难度 |
|------|----------|----------|------|
| **Kafka** | 3-6个月 | ISR、分区、ZK | ⭐⭐⭐⭐⭐ |
| **Pulsar** | 2-4个月 | BookKeeper、多租户、分层存储 | ⭐⭐⭐⭐ |
| **MQTT** | 1-2个月 | QoS、会话、主题 | ⭐⭐⭐ |
| **NATS** | 2-4周 | Subject、队列组 | ⭐⭐ |

## 📚 快速链接

- [详细对比分析](./01-基础概念与对比分析/01-01-多维度概念矩阵对比.md)
- [选型决策树](./01-基础概念与对比分析/01-03-决策图网分析.md)
- [场景化选型](./02-场景驱动架构设计/02-01-场景化功能架构矩阵.md)
- [运维实践](./03-架构与运维实践/03-02-成本模型与监控告警.md)

---

**更新日期**: 2025-12-31
