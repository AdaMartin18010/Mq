# TC-NATS-RS-DLQ-01：RS 客户端的 NATS 死信 用例

> **维度**：系统=NATS | 语言=RS | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given

- maxDeliver 耗尽→DLQ subject

## When

- 毒消息

## Then

- DLQ subject 收到
- delivery count 可观测
- 等级依据：TEST-C2 NATS×死信=◐

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/rs/死信/TC-NATS-RS-DLQ-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65
