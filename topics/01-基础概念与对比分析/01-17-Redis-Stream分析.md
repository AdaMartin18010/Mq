# 1.17 Redis Stream深度分析

## 目录

- [1.17 Redis Stream深度分析](#117-redis-stream深度分析)
  - [目录](#目录)
  - [1.17.1 Redis Stream概述](#1171-redis-stream概述)
  - [1.17.2 Redis Stream核心概念](#1172-redis-stream核心概念)
  - [1.17.3 Redis Stream与Kafka对比](#1173-redis-stream与kafka对比)
  - [1.17.4 Redis Stream应用场景](#1174-redis-stream应用场景)
  - [1.17.5 Redis Stream参考资源](#1175-redis-stream参考资源)

---

## 1.17.1 Redis Stream概述

**Redis Stream**是Redis 5.0引入的流数据结构，提供类似Kafka的消息流功能。

**核心特点**：

- ✅ 轻量级消息流
- ✅ 消费者组支持
- ✅ 消息持久化
- ✅ 低延迟

**适用场景**：

- 轻量级事件流
- 实时数据管道
- 日志聚合（小规模）

---

## 1.17.2 Redis Stream核心概念

**核心命令**：

```bash
# 添加消息
XADD mystream * field1 value1 field2 value2

# 读取消息
XREAD STREAMS mystream 0

# 创建消费者组
XGROUP CREATE mystream mygroup 0

# 消费者组读取
XREADGROUP GROUP mygroup consumer1 STREAMS mystream >
```

---

## 1.17.3 Redis Stream与Kafka对比

| 维度 | Redis Stream | Kafka |
|------|-------------|-------|
| **吞吐量** | 10-50万 TPS | 100万+ TPS |
| **延迟** | < 1ms | 5-100ms |
| **存储** | 内存（可持久化） | 磁盘 |
| **扩展性** | 单节点/集群 | 分布式集群 |
| **适用规模** | 中小规模 | 大规模 |

**选型建议**：

- **轻量级场景** → Redis Stream
- **大规模场景** → Kafka

---

## 1.17.4 Redis Stream应用场景

**1. 实时事件流**：

- 用户行为追踪
- 实时指标聚合

**2. 轻量级日志**：

- 应用日志收集
- 错误日志聚合

---

## 1.17.5 Redis Stream参考资源

- [Redis Streams文档](https://redis.io/docs/data-types/streams/)
- [Redis Streams教程](https://redis.io/docs/data-types/streams-tutorial/)

---

**最后更新**: 2025-12-31
