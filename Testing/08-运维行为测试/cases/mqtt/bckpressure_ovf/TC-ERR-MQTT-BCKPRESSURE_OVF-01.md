# TC-ERR-MQTT-BCKPRESSURE_OVF-01：MQTT 背压溢出 边界测试

> **维度**：系统=MQTT | 错误类=BCKPRESSURE_OVF | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 flow control / packet size — [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html) / [Merobix](https://www.merobix.com/blog/what-is-mqtt-maximum-packet-size)
> **环境**：E2；**状态**：pending

## Given

- 以高于消费速度的生产速率灌入，直至缓冲/队列/ack pending 满

## When

- 继续生产并观察 broker/客户端背压行为

## Then

- 超过 `Receive Maximum` 或 `Maximum Packet Size` 时 broker 暂停发送或返回 `0x93 Receive Maximum exceeded` / `0x95 Packet too large`
- 客户端启用阻塞/降速/丢帧策略，避免 OOM；恢复后自动恢复吞吐量
- metrics 显示 pending queue/内存/缓冲满/输出缓冲区超限

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/mqtt/bckpressure_ovf/TC-ERR-MQTT-BCKPRESSURE_OVF-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
