# TC-SCL-AUTOSCALE-KAFKA-03-01：自动伸缩 — KEDA maxReplicaCount 边界 ≤ 分区数

> **维度**：domain=SCL | subcat=AUTOSCALE | code=KAFKA-03 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic partition=6

## When

- lag 无限上涨

## Then

- 副本数≤6（allowIdleConsumers=false）
- KEDA 日志提示 idle consumer 禁止
- 无空转 consumer

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/autoscale/TC-SCL-AUTOSCALE-KAFKA-03-01.sh   # 计划打印（挂账）
```

## 关联

- 02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
