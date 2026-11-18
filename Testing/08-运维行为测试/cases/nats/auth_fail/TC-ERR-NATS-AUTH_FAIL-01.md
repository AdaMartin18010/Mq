# TC-ERR-NATS-AUTH_FAIL-01：NATS 认证/授权失败 边界测试

> **维度**：系统=NATS | 错误类=AUTH_FAIL | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS Authorization Violation — [NATS Authorization](https://docs.nats.io/learn/security/authorization) / [NATS System Errors](https://docs.nats.io/reference/system/errors)
> **环境**：E2；**状态**：pending

## Given

- 使用错误凭证或缺失凭证连接 broker

## When

- 客户端发起 CONNECT/SASL 握手或带 Token 的请求

## Then

- 认证/授权失败时 server 返回 `-ERR 'Authorization Violation'`，客户端进入重连退避
- 客户端停止发送并提示认证失败（不重试）
- broker 日志/auth 审计记录拒绝事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/auth_fail/TC-ERR-NATS-AUTH_FAIL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
