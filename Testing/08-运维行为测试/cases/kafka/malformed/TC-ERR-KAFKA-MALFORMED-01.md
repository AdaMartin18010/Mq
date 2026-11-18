# TC-ERR-KAFKA-MALFORMED-01：KAFKA 畸形消息 边界测试

> **维度**：系统=KAFKA | 错误类=MALFORMED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka `CORRUPT_MESSAGE` error code 2 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/CORRUPT_MESSAGE/) / [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)
> **环境**：E2；**状态**：pending

## Given

- 构造坏 JSON、超 frame、非法 UTF-8 或 CRC 错误的消息/帧

## When

- 发送/消费该畸形消息或帧

## Then

- CRC/size/null key 违规触发 `CorruptRecordException`，对应 `CORRUPT_MESSAGE`（error code 2）
- 客户端/ broker 拒绝该条消息并继续处理后续消息（不阻塞）
- 日志中出现 malformed/corrupt/schema/非法帧错误码

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/malformed/TC-ERR-KAFKA-MALFORMED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
