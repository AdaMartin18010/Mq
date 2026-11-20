# TC-ERR-ROCKETMQ-BCKPRESSURE_OVF-01：ROCKETMQ 背压溢出 边界测试

> **维度**：系统=ROCKETMQ | 错误类=BCKPRESSURE_OVF | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RocketMQ too much request flow control — [Stack Overflow](https://stackoverflow.com/questions/46767541/org-apache-rocketmq-remoting-exception-remotingtoomuchrequestexception-invokeas) / [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/)
> **环境**：E2；**状态**：pending

## Given

- 以高于消费速度的生产速率灌入，直至缓冲/队列/ack pending 满

## When

- 继续生产并观察 broker/客户端背压行为

## Then

- 异步发送过快触发 `RemotingTooMuchRequestException` / `broker busy`，客户端进入流控
- 客户端启用阻塞/降速/丢帧策略，避免 OOM；恢复后自动恢复吞吐量
- metrics 显示 pending queue/内存/缓冲满/输出缓冲区超限

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-ROCKETMQ-BCKPRESSURE_OVF-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
