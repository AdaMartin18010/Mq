# TC-ERR-MQTT-MALFORMED-01：MQTT 畸形消息 边界测试

> **维度**：系统=MQTT | 错误类=MALFORMED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 malformed 0x81/0x82 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 构造坏 JSON、超 frame、非法 UTF-8 或 CRC 错误的消息/帧

## When

- 发送/消费该畸形消息或帧

## Then

- 畸形包触发 server 发送 `0x81 Malformed Packet` 或 `0x82 Protocol Error` DISCONNECT
- 客户端/ broker 拒绝该条消息并继续处理后续消息（不阻塞）
- 日志中出现 malformed/corrupt/schema/非法帧错误码

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-MQTT-MALFORMED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
