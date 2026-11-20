# TC-ALT-METRICCHK-NATS-VARZ-01：指标正确性 — NATS /varz 指标与 nats-server 状态对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=NATS-VARZ | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66,03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 集群 3 node

## When

- 对比 /varz connections/memory 与 prometheus gnatsd_varz_*

## Then

- connections 数值一致
- memory 一致
- server_id 标签正确

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-METRICCHK-NATS-VARZ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66,03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
