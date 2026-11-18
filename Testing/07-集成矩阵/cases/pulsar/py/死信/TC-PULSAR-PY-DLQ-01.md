# TC-PULSAR-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=PULSAR | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- DLQ policy 经管理 API 配置

## When

- 毒消息 nack

## Then

- 入 DLQ topic
- policy 参数可回读校验（T3 链）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/pulsar/py/死信/TC-PULSAR-PY-DLQ-01.sh   # 计划打印
```

## 关联

- binding→配置映射 01-82 链#8
