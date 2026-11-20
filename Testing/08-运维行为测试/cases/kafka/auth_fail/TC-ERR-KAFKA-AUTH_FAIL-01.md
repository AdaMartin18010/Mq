# TC-ERR-KAFKA-AUTH_FAIL-01：KAFKA 认证/授权失败 边界测试

> **维度**：系统=KAFKA | 错误类=AUTH_FAIL | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka `SASL_AUTHENTICATION_FAILED` error code 58 — [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html) / [OneUptime](https://oneuptime.com/blog/post/2026-01-24-kafka-sasl-authentication-exception/view)
> **环境**：E2；**状态**：pending

## Given

- 使用错误凭证或缺失凭证连接 broker

## When

- 客户端发起 CONNECT/SASL 握手或带 Token 的请求

## Then

- SASL 握手失败抛出 `SaslAuthenticationException`，对应 `SASL_AUTHENTICATION_FAILED`（error code 58）
- 客户端停止发送并提示认证失败（不重试）
- broker 日志/auth 审计记录拒绝事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-KAFKA-AUTH_FAIL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
