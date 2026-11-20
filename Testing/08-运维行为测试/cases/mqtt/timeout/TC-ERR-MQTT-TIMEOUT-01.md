# TC-ERR-MQTT-TIMEOUT-01：MQTT 客户端超时族 边界测试

> **维度**：系统=MQTT | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 keep alive timeout 0x8D — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- Keep Alive 超时 server 发送 `0x8D Keep Alive timeout` DISCONNECT 并关闭连接
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-MQTT-TIMEOUT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
