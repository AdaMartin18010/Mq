# TC-SCL-PARTSCALE-KAFKA-02-01：分区伸缩 — Kafka 加分区后现有消息键映射保持

> **维度**：domain=SCL | subcat=PARTSCALE | code=KAFKA-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,01-72
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic 已有 10 万条 keyed 消息

## When

- 执行 --alter --partitions 6 后按 key 消费

## Then

- 消费顺序：旧 partition 内 key 顺序不变
- 新分区从 offset 0 开始
- 无消息重复或遗漏

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/partscale/TC-SCL-PARTSCALE-KAFKA-02-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61,01-72；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
