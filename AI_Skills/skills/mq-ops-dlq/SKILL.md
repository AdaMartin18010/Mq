---
name: mq-ops-dlq
description: >
  死信队列落地操作：DLX 声明、死信监控告警、死信重投（redrive）与清理的
  标准流程与检查清单，覆盖 Kafka/RabbitMQ/NATS/Pulsar 四系统。
  行为约束：对删除/清空类破坏性请求必须先拒绝并给出安全流程（先消费/转储后清理）。
  Use when DLQ 声明、死信监控、dlq redrive、死信重投、死信清理、
  dead letter queue 运维、死信处理流程、DLX 配置、poison message 处理、
  消息存储、备份恢复。
license: Apache-2.0
compatibility: Requires bash（重投脚本）；RabbitMQ/Kafka CLI 按需
metadata:
  source-doc: |
    topics/02-场景驱动架构设计/02-17-死信队列设计.md
    topics/03-架构与运维实践/03-44-消息存储与备份恢复指南.md
    topics/scripts/dlq-monitor.sh
  derived-at: "2026-11-18"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-18"
  status: active
---

# 死信队列落地操作

## 适用范围
- 按 `mq-pattern-dlq` 的论证结论实施 DLQ
- 日常死信监控、重投、清理运维

## 操作步骤
1. **声明死信承载**（按系统选一）：
   ```bash
   # RabbitMQ：主队列挂 DLX（参数见下）
   rabbitmqadmin declare exchange name=dlx type=direct durable=true
   rabbitmqadmin declare queue name=orders.dlq durable=true
   rabbitmqadmin declare binding source=dlx destination=orders.dlq routing_key=error
   rabbitmqadmin declare queue name=orders durable=true \
     arguments='{"x-dead-letter-exchange":"dlx","x-dead-letter-routing-key":"error","x-message-ttl":60000}'
   # Kafka：创建死信与分层重试 topic
   kafka-topics.sh --create --topic orders.dlq  --bootstrap-server <b> --partitions 3 --replication-factor 3
   kafka-topics.sh --create --topic orders.retry --bootstrap-server <b> --partitions 3 --replication-factor 3
   ```
2. **监控接入**：`./topics/scripts/dlq-monitor.sh all`（或本技能 scripts/dlq-monitor.sh）每日巡检；死信深度 > 0 即告警【阈值按业务定】。
3. **分析处理**：定位失败原因 → 修复 → 重投：`scripts/dlq-redrive.sh <system> <dlq> <target>`。
4. **清理**：重投完成且确认无误后，按保留策略清理死信（Kafka 靠 retention；RabbitMQ purge 需谨慎）。

## 验证
- [ ] 死信消息能被人工/脚本从 DLQ 读到（含原始 header/属性）
- [ ] 重投后消息到达目标 topic/queue 且格式完整
- [ ] 监控脚本能列出死信数量且告警链路可达

## 边界与红线
- 重投前必须修复根因，禁止"自动无限重投"（会再次打挂下游）。
- RabbitMQ `queue purge` 不可恢复，执行前必须快照死信样本。
- Kafka 死信 topic 的消息含失败原因 header（应用约定），重投时保留。

## 参考
- scripts/dlq-redrive.sh（重投脚本骨架）
- scripts/dlq-monitor.sh（薄封装，权威版 topics/scripts/dlq-monitor.sh）
- 互链技能：mq-pattern-dlq（设计论证）
