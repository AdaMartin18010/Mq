# TC-ERR-MQTT-AUTH_FAIL-01：MQTT 认证/授权失败 边界测试

> **维度**：系统=MQTT | 错误类=AUTH_FAIL | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 auth reason codes 0x86/0x87 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 使用错误凭证或缺失凭证连接 broker

## When

- 客户端发起 CONNECT/SASL 握手或带 Token 的请求

## Then

- CONNECT 认证失败返回 `0x86 Bad User Name or Password` 或 `0x87 Not authorized`
- 客户端停止发送并提示认证失败（不重试）
- broker 日志/auth 审计记录拒绝事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-MQTT-AUTH_FAIL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
