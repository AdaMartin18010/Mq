# TC-ALT-METRICCHK-PULSAR-RATE-01：指标正确性 — Pulsar broker 吞吐指标对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=PULSAR-RATE | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 固定速率生产

## When

- 对比 pulsar_broker_msg_in_rate 与 producer 计数

## Then

- 差值<5%【估算】
- broker 维度可下钻

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-PULSAR-RATE-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
