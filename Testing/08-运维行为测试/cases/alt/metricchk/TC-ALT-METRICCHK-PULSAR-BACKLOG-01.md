# TC-ALT-METRICCHK-PULSAR-BACKLOG-01：指标正确性 — Pulsar subscription backlog 指标对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=PULSAR-BACKLOG | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 生产 N 条未消费

## When

- 对比 pulsar_subscription_back_log 与实际

## Then

- backlog = 未消费数
- topic+subscription 标签正确

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-PULSAR-BACKLOG-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
