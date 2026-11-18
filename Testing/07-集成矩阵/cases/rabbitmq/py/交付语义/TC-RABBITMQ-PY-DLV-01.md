# TC-RABBITMQ-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=RABBITMQ | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- pika（py3.11+）durable 声明；publisher confirm 开启

## When

- 生产+重启

## Then

- confirm 返回后消息存活
- 无 confirm 消息允许丢失（至多一次边界）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rabbitmq/py/交付语义/TC-RABBITMQ-PY-DLV-01.sh   # 计划打印
```

## 关联

- 交付语义分级断言；01-73 客户端对照
