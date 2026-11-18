# TC-KAFKA-GO-DLQ-01：Go 客户端的 Kafka 死信断言（KIP-1191 路径）

> **维度**：系统=KAFKA | 语言=GO | 特性=DLQ（死信） | 转换链=T4
> **断言源**：01-65 DLQ 工程解析（KIP-1191 Share Groups DLQ，Kafka 4.4）
> **环境**：E2 docker；**状态**：pending。**镜像基线**：fixtures 已锁 apache/kafka:4.4.0（KIP-1191 解锁）

## Given

- Kafka 4.4+ 集群；share group `tc-dlq-share` 开启 share.dlq.topic=tc.dlq
- Go 消费者（sarama v1.61.1，显式 `Config.Version ≥ V2_1_1_0`——01-75 已证必需）；处理逻辑对含 `poison:true` 的消息持续返回失败

## When

1. 生产 100 条正常 + 5 条 poison
2. 消费端运行至 delivery count 达到上限（默认挂账值，执行批次标定）

## Then

- 5 条 poison 进入 `tc.dlq`，share partition 不再重投
- 正常 100 条全部完成（不被毒消息阻塞——share 语义无分区锁）
- DLQ topic 可独立消费取证

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/kafka/go/死信/TC-KAFKA-GO-DLQ-01.sh
```

## 关联

- 语义矩阵：TEST-C2 死信格（Kafka=◐，KIP-1191）
- 对照格：TC-RABBITMQ-GO-DLQ-01（DLX 原生路径，◐→● 对照）
- 知识：01-65 / 01-67 §1.67.5（share groups）
