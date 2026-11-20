# TC-ERR-RABBITMQ-VER_MISMATCH-01：RABBITMQ 协议/客户端版本不匹配 边界测试

> **维度**：系统=RABBITMQ | 错误类=VER_MISMATCH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ AMQP version mismatch — [juejin](https://juejin.cn/s/amqp%20protocol%20version%20mismatch%20we%20are%20version%200-9-1) / [pika spec](https://pika.readthedocs.io/en/stable/_modules/pika/spec.html)
> **环境**：E2；**状态**：pending

## Given

- 使用旧版客户端或错误协议版本连接当前 broker

## When

- 进行协议握手或 ApiVersions 协商

## Then

- AMQP 0-9-1/1.0 协议或客户端版本不兼容导致握手失败，返回 `NOT_IMPLEMENTED`（540）或 `protocol version mismatch`
- 客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）
- broker 日志记录不支持的协议/客户端版本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-RABBITMQ-VER_MISMATCH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
