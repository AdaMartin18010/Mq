# TC-MQTT-GO-DLV-01：GO 客户端的 交付语义 断言

> **维度**：系统=MQTT | 语言=GO | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- mosquitto 模板；paho.mqtt.golang v1.5.1；QoS1+cleanSession=false

## When

- QoS1 发布 500→订阅者重启

## Then

- inflight 重投（至少一次）
- QoS0 消息允许丢失（对照组）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/mqtt/go/交付语义/TC-MQTT-GO-DLV-01.sh   # 计划打印
```

## 关联

- 01-64 QoS 时序【定理】；语义矩阵 MQTT=●
