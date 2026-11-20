# TC-ALT-METRICCHK-KAFKA-TPUT-01：指标正确性 — Kafka throughput 指标与压测实际对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=KAFKA-TPUT | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 固定速率生产

## When

- 对比 kafka_server_brokertopicmetrics_messagesinpersec 与 producer 计数

## Then

- 差值<5%【估算】
- topic 维度可下钻
- broker 维度求和一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-METRICCHK-KAFKA-TPUT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
