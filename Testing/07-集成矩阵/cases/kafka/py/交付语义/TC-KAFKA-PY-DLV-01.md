# TC-KAFKA-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=KAFKA | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 3 broker KRaft；aiokafka 0.15.0 消费者 enable_auto_commit=False；生产者 acks=all

## When

- 生产 500 条后 kill 一副本

## Then

- 已确认消息可全量消费（ASE-001）
- 手动 commit 语义下次重启不重复（EOS 边界 01-63）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/kafka/py/交付语义/TC-KAFKA-PY-DLV-01.sh   # 计划打印
```

## 关联

- 对照 TC-KAFKA-GO-DLV-01（金样本边）；01-73 asyncio 消费模式
