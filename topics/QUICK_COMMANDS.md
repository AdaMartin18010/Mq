# 快速命令参考

## 目录

- [快速命令参考](#快速命令参考)
  - [目录](#目录)
  - [部署命令](#部署命令)
  - [管理命令](#管理命令)
  - [监控命令](#监控命令)
  - [故障排查命令](#故障排查命令)

---

## 部署命令

### Kafka

```bash
# 部署
./scripts/deploy-kafka.sh

# 启动
./scripts/start.sh kafka

# 停止
./scripts/stop.sh kafka

# 重启
./scripts/restart.sh kafka
```

### NATS

```bash
# 部署
./scripts/deploy-nats.sh

# 启动
./scripts/start.sh nats

# 停止
./scripts/stop.sh nats
```

### RabbitMQ

```bash
# 部署
./scripts/deploy-rabbitmq.sh

# 启动
./scripts/start.sh rabbitmq

# 停止
./scripts/stop.sh rabbitmq
```

---

## 管理命令

### 状态检查

```bash
# 检查所有系统状态
./scripts/status.sh all

# 检查单个系统
./scripts/status.sh kafka
./scripts/status.sh nats
./scripts/status.sh rabbitmq
```

### 健康检查

```bash
./scripts/health-check.sh kafka
./scripts/health-check.sh nats
./scripts/health-check.sh rabbitmq
```

### 日志查看

```bash
./scripts/logs.sh kafka 100
./scripts/logs.sh nats 50
./scripts/logs.sh rabbitmq 200
```

---

## 监控命令

### 实时监控

```bash
./scripts/monitor.sh kafka
./scripts/monitor.sh nats
./scripts/monitor.sh rabbitmq
```

### 性能分析

```bash
./scripts/performance-analyze.sh kafka
./scripts/performance-analyze.sh nats
```

---

## 故障排查命令

### 故障诊断

```bash
./scripts/diagnose.sh kafka
./scripts/diagnose.sh nats
./scripts/diagnose.sh rabbitmq
```

### 性能测试

```bash
./scripts/benchmark.sh kafka 60 10000
./scripts/performance-test.sh nats
```

---

**最后更新**: 2025-12-31
