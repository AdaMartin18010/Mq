# TC-NATS-GO-DLQ-01：GO 客户端的 死信 断言

> **维度**：系统=NATS | 语言=GO | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- maxDeliver=5 + DLQ subject 配置

## When

- 消费者持续 nak 毒消息

## Then

- 投递计数达上限转 DLQ subject
- maxDeliver 计数可观测（delivery count）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/go/死信/TC-NATS-GO-DLQ-01.sh   # 计划打印
```

## 关联

- 01-65 NATS 路径；x-jetstream.maxDeliver 绑定映射
