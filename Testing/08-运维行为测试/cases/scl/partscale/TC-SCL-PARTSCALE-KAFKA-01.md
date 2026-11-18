# TC-SCL-PARTSCALE-KAFKA-01：分区伸缩 — Kafka 运行中加分区期间生产不中断

> **维度**：domain=SCL | subcat=PARTSCALE | code=KAFKA-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,02-49,08-运维行为测试
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker / 3 partition topic / acks=all 持续生产

## When

- kafka-topics --alter --partitions 6

## Then

- 生产端无 RecordBatch Expired 异常
- __consumer_offsets 重平衡在 max.poll.interval 内完成
- 新增分区 leader 分布可观测（kafka-log-dirs）
- 键映射保持：同一 key 仍路由到同一分区（旧 key 范围不变）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/partscale/TC-SCL-PARTSCALE-KAFKA-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61,02-49,08-运维行为测试；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
