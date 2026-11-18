# TC-PULSAR-GO-DLQ-01：GO 客户端的 死信 断言

> **维度**：系统=PULSAR | 语言=GO | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- namespace DLQ policy（maxRedeliverCount）；nack 触发

## When

- 毒消息消费失败

## Then

- 重投递达上限入 DLQ topic
- 原订阅游标推进不被毒消息卡死

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/pulsar/go/死信/TC-PULSAR-GO-DLQ-01.sh   # 计划打印
```

## 关联

- 01-65 Pulsar 路径（DLQ policy 原生）
