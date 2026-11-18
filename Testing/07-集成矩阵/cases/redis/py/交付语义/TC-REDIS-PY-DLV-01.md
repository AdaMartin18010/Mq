# TC-REDIS-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=REDIS | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- redis-py asyncio；AOF 持久化

## When

- 生产+重启

## Then

- XLEN 保持
- 消费组 PEL 可重放

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/py/交付语义/TC-REDIS-PY-DLV-01.sh   # 计划打印
```

## 关联

- 01-73 Redis 客户端
