# TC-REDIS-GO-DLQ-01：GO 客户端的 死信 断言

> **维度**：系统=REDIS | 语言=GO | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 应用层模式：PEL 超阈值 XAUTOCLAIM 转死信 Stream

## When

- 毒消息不 ACK

## Then

- 超阈值入 dlq Stream
- 主 Stream 长度受 MAXLEN 约束

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/go/死信/TC-REDIS-GO-DLQ-01.sh   # 计划打印
```

## 关联

- 01-65 Redis 路径（无原生 DLQ）；模式用例
