# TC-MQTT-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=MQTT | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- paho 2.2.0；sessionExpiryInterval=300（v5 属性）

## When

- 离线期间 QoS1 发布→重连

## Then

- 会话期内消息补投
- 过期会话消息丢弃（ASE-012 族）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/mqtt/py/交付语义/TC-MQTT-PY-DLV-01.sh   # 计划打印
```

## 关联

- 01-64 会话状态机
