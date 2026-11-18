# TC-RABBITMQ-TS-DLQ-01：TS 客户端的 RABBITMQ 死信 用例

> **维度**：系统=RABBITMQ | 语言=TS | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given
- DLX 绑定；nack(requeue=false)

## When
- 毒消息

## Then
- 入 DLQ 原队列清空（ASE-007）
- DLQ 可再消费
- 等级依据：TEST-C2 RABBITMQ×死信=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/ts/死信/TC-RABBITMQ-TS-DLQ-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65 AMQP 路径
