# TC-NATS-RS-DLV-01：RS 客户端的 NATS 交付语义 用例

> **维度**：系统=NATS | 语言=RS | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given

- JetStream workqueue+explicit ack；Core 至多一次对照

## When

- 消费端中断重启

## Then

- 未 ack 重投
- AckFloor 单调
- 等级依据：TEST-C2 NATS×交付语义=◐

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/rs/交付语义/TC-NATS-RS-DLV-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66
