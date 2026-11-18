# TC-MQTT-PY-DLQ-01：PY 客户端的 死信 断言

> **维度**：系统=MQTT | 语言=PY | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 同 GO 应用层模式 Python 实现

## When

- 失败消息

## Then

- $dlq 隔离
- 与 Go 实现对拍

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/mqtt/py/死信/TC-MQTT-PY-DLQ-01.sh   # 计划打印
```

## 关联

- XLAN-B 边
