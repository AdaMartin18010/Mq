# TC-ALT-METRICCHK-NATS-PENDING-01：指标正确性 — NATS JetStream pending 指标与实际未 ack 对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=NATS-PENDING | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 发布 N 条未 ack

## When
- 对比 nats_jetstream_consumer_num_pending 与实际

## Then
- pending = 未 ack 数
- consumer+stream 标签正确
- ack 后同步归零

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-NATS-PENDING-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
