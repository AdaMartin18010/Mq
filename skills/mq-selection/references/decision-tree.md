# 决策树切片（派生自 01-03/01-20，派生日 2026-11-17）

> **时效声明**: 本文事实核实至 2026-01（随源文档）；选型结论为【论证】级工程推理。

## 分层决策流程

```text
需要持久化？
├─ 是 → 需要高吞吐量？
│   ├─ 是 → Kafka 或 Pulsar
│   │        （多租户/地理复制优先 → Pulsar；生态/吞吐优先 → Kafka）
│   └─ 否 → RabbitMQ 或 Redis Stream
│            （复杂路由/企业集成 → RabbitMQ；轻量流/已有 Redis → Redis Stream）
└─ 否 → 需要最低延迟/海量连接？
    ├─ 是 → NATS Core
    └─ 否 → MQTT（设备/移动）或 NATS（服务间）
```

## 场景速查（01-20.1）

| 场景 | 推荐 | 备选 |
|------|------|------|
| 日志聚合 | Kafka | Pulsar |
| IoT 设备 | MQTT | NATS |
| 微服务通信 | NATS | RabbitMQ, Pulsar |
| 任务队列 | RabbitMQ | NATS, Redis Stream |
| 事件流处理 | Kafka | Pulsar |
| 实时通信 | NATS | Redis Stream |
| 大数据分析 | Kafka | Pulsar |
| 移动推送 | MQTT | NATS |

## 一句话选型（01-20.4）

- 日志/事件流 → Kafka；IoT 设备 → MQTT；微服务实时通信 → NATS
- 任务队列 → RabbitMQ；轻量级流处理 → Redis Stream；云原生多租户 → Pulsar

---
**同步规则**: 源文档更新后须重新派生并更新 derived-at / last-verified（见 AI_SKILL-02 AIS.02.5）。
