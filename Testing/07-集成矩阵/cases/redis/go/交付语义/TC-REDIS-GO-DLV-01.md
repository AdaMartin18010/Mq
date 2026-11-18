# TC-REDIS-GO-DLV-01：GO 客户端的 交付语义 断言

> **维度**：系统=REDIS | 语言=GO | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- go-redis v9.23.0；AOF everysec；Stream 消费组

## When

- XADD 500 条后实例重启

## Then

- Stream 长度=500 且 last-ID 不回落（ASE-014 族）
- 未 ACK 条目在 PEL 重投

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/go/交付语义/TC-REDIS-GO-DLV-01.sh   # 计划打印
```

## 关联

- 语义矩阵 Redis=○（应用层）；01-66 Redis 节
