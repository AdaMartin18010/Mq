# TC-ERR-RABBITMQ-QUOTA_EXCEED-01：RABBITMQ 配额超限 边界测试

> **维度**：系统=RABBITMQ | 错误类=QUOTA_EXCEED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ per-user limits & AMQP error codes — [Alibaba Cloud Error Codes](https://www.alibabacloud.com/help/en/apsaramq-for-rabbitmq/developer-reference/error-codes-returned-when-amqp-methods-are-called) / [CloudAMQP](https://www.cloudamqp.com/blog/connection-limit-per-user-feature/)
> **环境**：E2；**状态**：pending

## Given

- 将某用户/流/租户压测至配置配额上限

## When

- 持续发送直到触发配额/限速/存储上限

## Then

- per-user 连接/通道数或队列长度超限返回 `ConnectionNumExceeded`（530）/ `RESOURCE_LOCKED`（405）/ `channelMax limit reached`
- 客户端收到配额超限信号后启用退避/降速，不硬失败
- admin/metrics 显示 throttle/reject/配额指标上升

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/quota_exceed/TC-ERR-RABBITMQ-QUOTA_EXCEED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
