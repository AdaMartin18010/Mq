# TC-RABBITMQ-GO-DLV-01：GO 客户端的 交付语义 断言

> **维度**：系统=RABBITMQ | 语言=GO | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- rabbitmq.conf.template 应用；amqp091-go v1.17.0；durable queue + persistent 消息

## When

- 生产 500 条持久消息后 broker 重启

## Then

- 重启后队列深度=500（PST 联动断言）
- consumer ack 后消息移除（≥at-least-once）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rabbitmq/go/交付语义/TC-RABBITMQ-GO-DLV-01.sh   # 计划打印
```

## 关联

- 语义矩阵交付语义格 RabbitMQ=●；01-42 AMQP 语义
