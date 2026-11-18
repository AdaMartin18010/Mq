# TC-RABBITMQ-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=RABBITMQ | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- pika basic_nack(requeue=False)

## When

- poison 处理异常

## Then

- DLX 路由命中
- binding key 匹配原 routing

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rabbitmq/py/死信/TC-RABBITMQ-PY-DLQ-01.sh   # 计划打印
```

## 关联

- AMQP 0.3.0 binding is 字段语义（01-86）
