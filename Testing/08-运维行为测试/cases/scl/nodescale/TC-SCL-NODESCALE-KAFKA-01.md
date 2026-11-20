# TC-SCL-NODESCALE-KAFKA-01：节点伸缩 — Kafka broker 扩容后分区迁移可观测

> **维度**：domain=SCL | subcat=NODESCALE | code=KAFKA-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker / 6 partition

## When

- 启动第 4 broker

## Then

- 分区副本开始迁移（kafka-reassign-partitions --verify）
- UnderReplicatedPartitions 峰值可控
- 迁移进度百分比可计算

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-KAFKA-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61,02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
