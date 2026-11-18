# TC-REDIS-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=REDIS | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 同 GO 模式 Python 实现

## When

- 毒消息

## Then

- 死信 Stream 隔离
- 模式与 Go 实现对拍（XLAN-B 边）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/py/死信/TC-REDIS-PY-DLQ-01.sh   # 计划打印
```

## 关联

- 01-77 跨语言对等
