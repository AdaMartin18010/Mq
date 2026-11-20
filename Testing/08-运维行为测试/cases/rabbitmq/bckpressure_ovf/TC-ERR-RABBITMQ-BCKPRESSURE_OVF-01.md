# TC-ERR-RABBITMQ-BCKPRESSURE_OVF-01：RABBITMQ 背压溢出 边界测试

> **维度**：系统=RABBITMQ | 错误类=BCKPRESSURE_OVF | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ memory alarm / connection.blocked — [Netdata](https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/) / [DevOps AI Toolkit](https://devopsaitoolkit.com/blog/rabbitmq-error-connection-blocked-notification/)
> **环境**：E2；**状态**：pending

## Given

- 以高于消费速度的生产速率灌入，直至缓冲/队列/ack pending 满

## When

- 继续生产并观察 broker/客户端背压行为

## Then

- 内存/磁盘 watermark 触发资源告警，broker 向发布连接发送 `connection.blocked` 帧，publish 挂起
- 客户端启用阻塞/降速/丢帧策略，避免 OOM；恢复后自动恢复吞吐量
- metrics 显示 pending queue/内存/缓冲满/输出缓冲区超限

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-RABBITMQ-BCKPRESSURE_OVF-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
