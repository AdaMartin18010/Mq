# TC-ALT-METRICCHK-KAFKA-LAG-01：指标正确性 — Kafka consumergroup lag 指标与实际情况对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=KAFKA-LAG | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 生产 N 条 / 消费 M 条

## When

- 对比 kafka_consumergroup_lag 与 实际 offset 差

## Then

- 指标 lag = 实际未消费数
- 按 group+topic+partition 聚合正确
- JMX exporter 无标签丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-KAFKA-LAG-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61,03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
