# TC-SCL-PARTSCALE-KAFKA-03-01：分区伸缩 — Kafka 分区重分配期间吞吐影响

> **维度**：domain=SCL | subcat=PARTSCALE | code=KAFKA-03 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,03-67
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic 6 分区 / 生产消费压测

## When

- kafka-reassign-partitions --execute --throttle

## Then

- throttle 字节率生效（指标 kafka_server_replicamanager_replication_throttled_rate）
- 生产吞吐下降≤30%【估算】
- 重分配完成后 URP=0
- 数据校验和完整

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-PARTSCALE-KAFKA-03-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61,03-67；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
