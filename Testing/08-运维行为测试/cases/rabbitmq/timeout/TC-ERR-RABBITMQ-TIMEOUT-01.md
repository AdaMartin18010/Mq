# TC-ERR-RABBITMQ-TIMEOUT-01：RABBITMQ 客户端超时族 边界测试

> **维度**：系统=RABBITMQ | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ heartbeat/connection reset — [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view) / [GitHub amqplib](https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- 心跳超时或 TCP 握手超时触发 `HEARTBEAT_TIMEOUT` / `Connection reset by peer`，连接被 broker 关闭
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/timeout/TC-ERR-RABBITMQ-TIMEOUT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
