# TC-ERR-PULSAR-TIMEOUT-01：PULSAR 客户端超时族 边界测试

> **维度**：系统=PULSAR | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Pulsar sendTimeout default 30s — [Pulsar Client Java API](https://pulsar.apache.org/api/client/4.0.x/index-all.html) / [pulsar-client-go #1312](https://github.com/apache/pulsar-client-go/issues/1312)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- producer `sendTimeout` 默认 30000ms 内未收到 ack 时抛出 `PulsarClientException.TimeoutException`
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-PULSAR-TIMEOUT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
