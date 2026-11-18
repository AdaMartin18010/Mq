# TC-KAFKA-GO-DLV-01：Go 客户端的 Kafka at-least-once 交付断言

> **维度**：系统=KAFKA | 语言=GO | 特性=DLV（交付语义） | 转换链=T3,T4
> **断言源**：ASE-001（acks=all+min.insync.replicas=2 下已确认消息不丢）
> **环境**：E2 docker；**状态**：pending

## Given

- fixtures compose 起 3 broker Kafka（KRaft 单控制器），`min.insync.replicas=2`
- config-templates/kafka-server.properties.template 应用；Go 客户端 confluent-kafka-go v2.16.1（librdkafka 2.16.0）
- 生产者 `acks=all`、`enable.idempotence=true`；topic `tc.dlv` partitions=3 replicationFactor=3

## When

1. 生产 500 条（key 散列三分区），消费端记录已收 offset
2. 其中一副本 broker 在确认后 5s 内 `docker kill`（非优雅）
3. 等待 ISR 重选完成

## Then

- 已确认消息全部仍可消费（存在性断言，ASE-001 主断言）
- 消费重复计数 ≤1（at-least-once 的重复上界）
- 生产者无消息丢失错误（delivery report 全 success）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/kafka/go/交付语义/TC-KAFKA-GO-DLV-01.sh   # 计划打印
```

## 关联

- 语义矩阵：TEST-C2 交付语义格（Kafka=●）
- 设计/落地：02-16 → 03-16；协议面：01-71 acks 语义
- 跨语言同格：TC-KAFKA-PY-DLV-01（金样本对账边，01-77）
