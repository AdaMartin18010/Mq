# TC-ERR-KAFKA-UNKWON_TOPIC-01：KAFKA 未知 topic/queue/stream 边界测试

> **维度**：系统=KAFKA | 错误类=UNKWON_TOPIC | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka `UNKNOWN_TOPIC_OR_PARTITION` error code 3 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/UNKNOWN_TOPIC_OR_PARTITION/) / [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)
> **环境**：E2；**状态**：pending

## Given

- 目标 topic/queue/stream 未创建或已被删除

## When

- 客户端向该不存在的资源执行 publish/consume/declare/create group

## Then

- 客户端收到 `org.apache.kafka.common.errors.UnknownTopicOrPartitionException`（error code 3），`request.timeout.ms` 默认 30000ms 后抛出
- 客户端在超时/重试窗口内尝试恢复，持续失败则快速失败
- broker 日志或 admin 接口显示资源不存在/404/未知 topic 错误

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-KAFKA-UNKWON_TOPIC-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
