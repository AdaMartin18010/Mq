# TC-ERR-PULSAR-BCKPRESSURE_OVF-01：PULSAR 背压溢出 边界测试

> **维度**：系统=PULSAR | 错误类=BCKPRESSURE_OVF | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Pulsar producer queue full — [Pulsar Client Java API](https://pulsar.apache.org/api/client/4.0.x/index-all.html) / [jianshu producer async](https://www.jianshu.com/p/78112dcb3436)
> **环境**：E2；**状态**：pending

## Given

- 以高于消费速度的生产速率灌入，直至缓冲/队列/ack pending 满

## When

- 继续生产并观察 broker/客户端背压行为

## Then

- producer pending queue 满且 `blockIfQueueFull=false` 时抛出 `ProducerQueueIsFullError`
- 客户端启用阻塞/降速/丢帧策略，避免 OOM；恢复后自动恢复吞吐量
- metrics 显示 pending queue/内存/缓冲满/输出缓冲区超限

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/bckpressure_ovf/TC-ERR-PULSAR-BCKPRESSURE_OVF-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
