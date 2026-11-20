# TC-ERR-RABBITMQ-CONN_RESET-01：RABBITMQ 连接重置/半开连接 边界测试

> **维度**：系统=RABBITMQ | 错误类=CONN_RESET | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ connection reset — [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view) / [GitHub Azure Functions](https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159)
> **环境**：E2；**状态**：pending

## Given

- 在连接活动期间注入 TCP RST 或半开连接/强制关闭 broker 端口

## When

- 观察客户端在连接异常关闭后的行为

## Then

- TCP 连接被 RST 或 broker 异常关闭，客户端收到 `Socket closed abruptly` / `Connection reset by peer`
- 客户端自动重连并恢复会话/订阅；重连风暴可控
- 日志记录连接断开与恢复事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-RABBITMQ-CONN_RESET-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
