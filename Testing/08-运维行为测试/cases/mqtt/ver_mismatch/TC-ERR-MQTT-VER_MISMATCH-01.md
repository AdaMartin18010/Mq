# TC-ERR-MQTT-VER_MISMATCH-01：MQTT 协议/客户端版本不匹配 边界测试

> **维度**：系统=MQTT | 错误类=VER_MISMATCH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 unsupported protocol version 0x84 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 使用旧版客户端或错误协议版本连接当前 broker

## When

- 进行协议握手或 ApiVersions 协商

## Then

- 客户端请求不支持的协议版本时 server 返回 `0x84 Unsupported Protocol Version`
- 客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）
- broker 日志记录不支持的协议/客户端版本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/mqtt/ver_mismatch/TC-ERR-MQTT-VER_MISMATCH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
