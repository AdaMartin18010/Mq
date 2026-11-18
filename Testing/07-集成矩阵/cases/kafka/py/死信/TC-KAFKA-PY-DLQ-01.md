# TC-KAFKA-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=KAFKA | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 同 GO 格前置（Kafka 4.4+ 挂账）

## When

- poison 消息生产+share 消费

## Then

- 毒消息入 tc.dlq
- 正常消息零阻塞

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/kafka/py/死信/TC-KAFKA-PY-DLQ-01.sh   # 计划打印
```

## 关联

- 01-75 sarama 对照；01-65 KIP-1191 节
