# 快速入门指南

## 目录

- [快速入门指南](#快速入门指南)
  - [目录](#目录)
  - [1. 项目概览](#1-项目概览)
  - [2. 快速导航](#2-快速导航)
  - [3. 技术选型快速决策](#3-技术选型快速决策)
  - [4. 部署快速开始](#4-部署快速开始)
  - [5. 常用命令速查](#5-常用命令速查)
  - [6. 故障排查快速参考](#6-故障排查快速参考)

---

## 1. 项目概览

本项目提供Kafka、MQTT、NATS、Pulsar、RabbitMQ、Redis Stream六大消息队列系统的全面分析、对比和实践指南。

### 项目结构

```
topics/
├── 01-基础概念与对比分析/    # 基础概念、对比分析、选型指南
├── 02-场景驱动架构设计/      # 场景化架构设计、最佳实践
├── 03-架构与运维实践/        # 部署、运维、监控、安全
├── scripts/                  # 实用脚本工具
├── config-templates/         # 配置模板
└── examples/                 # 代码示例
```

---

## 2. 快速导航

### 新手入门路径

1. **第一步**: 阅读 [首次阅读指南](./README_FIRST.md)
2. **第二步**: 查看 [快速参考卡片](./01-基础概念与对比分析/01-21-快速参考卡片.md)
3. **第三步**: 阅读 [技术选型速查表](./01-基础概念与对比分析/01-20-技术选型速查表.md)
4. **第四步**: 查看 [常见问题FAQ](./01-基础概念与对比分析/01-22-常见问题FAQ.md)

### 技术选型路径

1. **需求分析**: [选型决策矩阵](./01-基础概念与对比分析/01-19-选型决策矩阵.md)
2. **场景匹配**: [场景化功能架构矩阵](./02-场景驱动架构设计/02-01-场景化功能架构矩阵.md)
3. **性能对比**: [性能基准测试对比](./01-基础概念与对比分析/01-18-性能基准测试对比.md)
4. **最终决策**: [技术选型速查表](./01-基础概念与对比分析/01-20-技术选型速查表.md)

### 架构设计路径

1. **场景分析**: [场景驱动架构设计](./02-场景驱动架构设计/)
2. **高可用设计**: [高可用架构设计](./02-场景驱动架构设计/02-10-高可用架构设计.md)
3. **性能优化**: [性能优化案例](./02-场景驱动架构设计/02-09-性能优化案例.md)
4. **最佳实践**: [最佳实践总结](./03-架构与运维实践/03-24-最佳实践总结.md)

---

## 3. 技术选型快速决策

### 场景 → 技术选型

| 场景 | 推荐技术 | 理由 |
|------|---------|------|
| 日志聚合 | Kafka | 高吞吐、持久化、分区支持 |
| IoT设备通信 | MQTT | 轻量级、低带宽、QoS支持 |
| 微服务通信 | NATS | 低延迟、简单、高性能 |
| 金融交易 | Kafka + 事务 | 强一致性、持久化 |
| 实时通知 | NATS | 低延迟、高并发 |
| 任务队列 | RabbitMQ | 灵活路由、死信队列 |

### 性能需求 → 技术选型

| 需求 | 推荐技术 | 性能指标 |
|------|---------|---------|
| 超高吞吐量 | Kafka | 100万+ TPS |
| 超低延迟 | NATS | <1ms |
| 高可靠性 | Kafka/Pulsar | 持久化、副本 |
| 轻量级 | MQTT | 最小2字节 |

---

## 4. 部署快速开始

### Docker Compose一键启动

```bash
# 启动所有系统
cd config-templates
docker-compose -f docker-compose-all.yml up -d

# 或启动单个系统
docker-compose -f docker-compose-kafka.yml up -d
```

### 使用部署脚本

```bash
# 快速启动
./scripts/quick-start.sh

# 健康检查
./scripts/health-check-all.sh

# 监控设置
./scripts/monitor-setup.sh
```

---

## 5. 常用命令速查

### Kafka

```bash
# 创建Topic
kafka-topics.sh --create --topic orders --partitions 3 --replication-factor 2

# 查看Topic列表
kafka-topics.sh --list

# 生产消息
kafka-console-producer.sh --topic orders --bootstrap-server localhost:9092

# 消费消息
kafka-console-consumer.sh --topic orders --from-beginning --bootstrap-server localhost:9092
```

### NATS

```bash
# 启动服务器
nats-server

# 发布消息
nats pub orders "Hello NATS"

# 订阅消息
nats sub orders
```

### RabbitMQ

```bash
# 查看队列
rabbitmqctl list_queues

# 查看连接
rabbitmqctl list_connections

# 管理界面
# http://localhost:15672 (guest/guest)
```

---

## 6. 故障排查快速参考

### 常见问题

1. **连接失败**
   - 检查服务是否运行: `./scripts/health-check-all.sh`
   - 检查端口是否开放
   - 检查防火墙规则

2. **消息丢失**
   - 检查持久化配置
   - 检查ACK机制
   - 查看死信队列

3. **性能问题**
   - 查看监控指标: `./scripts/monitor-check.sh`
   - 检查资源使用: `./scripts/resource-usage.sh`
   - 性能分析: `./scripts/performance-analysis.sh`

### 故障排查流程

1. **健康检查**: `./scripts/health-check-all.sh`
2. **日志查看**: `./scripts/logs-tail.sh`
3. **诊断分析**: `./scripts/diagnostics.sh`
4. **故障排查**: `./scripts/troubleshoot.sh`

---

**最后更新**: 2025-12-31
