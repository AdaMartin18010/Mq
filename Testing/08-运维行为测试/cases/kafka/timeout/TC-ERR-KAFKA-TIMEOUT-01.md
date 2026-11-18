# TC-ERR-KAFKA-TIMEOUT-01：KAFKA 客户端超时族 边界测试

> **维度**：系统=KAFKA | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka `request.timeout.ms` default 30000ms — [Baeldung](https://www.baeldung.com/java-kafka-timeoutexception) / [Apache Kafka Producer Configs](https://kafka.apache.org/41/configuration/producer-configs/)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- 客户端抛出 `TimeoutException` / `RequestTimeoutException`，`request.timeout.ms` 默认 30000ms，`default.api.timeout.ms` 默认 60000ms
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/timeout/TC-ERR-KAFKA-TIMEOUT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
