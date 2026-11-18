# TC-RABBITMQ-GO-DLQ-01：GO 客户端的 死信 断言

> **维度**：系统=RABBITMQ | 语言=GO | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 队列绑 DLX（config 模板 dlx 段）；消费者 nack(requeue=false)

## When

- 100 正常+5 poison 消费

## Then

- poison 入 DLQ 且原队列清空（ASE-007 族）
- DLQ 可消费再处理

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rabbitmq/go/死信/TC-RABBITMQ-GO-DLQ-01.sh   # 计划打印
```

## 关联

- 01-65 AMQP 路径（DLX 原生）；TC-KAFKA-GO-DLQ-01 对照
