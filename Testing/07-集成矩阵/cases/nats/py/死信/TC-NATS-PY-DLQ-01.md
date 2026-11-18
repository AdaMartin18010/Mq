# TC-NATS-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=NATS | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- jetstream 管理 API 建 consumer max_deliver=5

## When

- 毒消息 nak

## Then

- max_deliver 耗尽进 DLQ 配置项
- 管理 API 可见 delivery_count

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/死信/TC-NATS-PY-DLQ-01.sh   # 计划打印
```

## 关联

- 01-66 NATS pull 节
