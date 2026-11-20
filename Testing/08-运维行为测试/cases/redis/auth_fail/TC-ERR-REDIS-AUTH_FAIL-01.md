# TC-ERR-REDIS-AUTH_FAIL-01：REDIS 认证/授权失败 边界测试

> **维度**：系统=REDIS | 错误类=AUTH_FAIL | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Redis WRONGPASS — [Alibaba Cloud](https://www.alibabacloud.com/help/en/redis/support/what-do-i-do-if-the-wrongpass-invalid-username-password-pair-error-message-is-returned-when-i-attempt-to-connect-to-an-apsaradb-for-redis-instance) / [Redis AUTH](https://redis.io/docs/latest/commands/auth/)
> **环境**：E2；**状态**：pending

## Given

- 使用错误凭证或缺失凭证连接 broker

## When

- 客户端发起 CONNECT/SASL 握手或带 Token 的请求

## Then

- ACL/密码错误返回 `WRONGPASS invalid username-password pair` / `NOAUTH Authentication required`
- 客户端停止发送并提示认证失败（不重试）
- broker 日志/auth 审计记录拒绝事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-REDIS-AUTH_FAIL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
