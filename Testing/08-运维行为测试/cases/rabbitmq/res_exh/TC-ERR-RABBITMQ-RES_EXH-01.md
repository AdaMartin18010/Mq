# TC-ERR-RABBITMQ-RES_EXH-01：RABBITMQ 资源耗尽 边界测试

> **维度**：系统=RABBITMQ | 错误类=RES_EXH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ resource exhaustion — [Netdata Memory Alarm](https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/) / [CloudAMQP Monitoring](https://www.cloudamqp.com/blog/monitoring-rabbitmq-in-production/)
> **环境**：E2；**状态**：pending

## Given

- 将 broker 节点的 FD/内存/磁盘压至上限

## When

- 继续请求并观察 broker 降级行为

## Then

- Erlang VM 内存超过 watermark 或 FD 耗尽触发资源告警，broker 阻塞发布并记录 `memory resource limit alarm`
- broker 进入只读/拒绝新连接；清理资源后自动恢复
- metrics 显示 FD/内存/磁盘耗尽报警

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/res_exh/TC-ERR-RABBITMQ-RES_EXH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
