# TC-NATS-GO-DLV-01：GO 客户端的 交付语义 断言

> **维度**：系统=NATS | 语言=GO | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- JetStream workqueue stream；durable pull consumer explicit ack

## When

- 生产→kill 消费端→重启

## Then

- 未 ack 消息重投（at-least-once）
- ack 过的不重（AckFloor 单调）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/go/交付语义/TC-NATS-GO-DLV-01.sh   # 计划打印
```

## 关联

- 语义矩阵 NATS=◐（JetStream 启用后）；01-66 JetStream 节
