# TC-SCL-AUTOSCALE-KAFKA-02-01：自动伸缩 — KEDA 缩容冷却期生效

> **维度**：domain=SCL | subcat=AUTOSCALE | code=KAFKA-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：02-49,04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- lag 恢复正常后

## When

- 等待 cooldownPeriod=300s

## Then

- 副本数不立即下降
- 冷却期内消费完成
- 最终回到 minReplicaCount

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-AUTOSCALE-KAFKA-02-01   # 计划打印（dry-run RC=0）
```

## 关联

- 02-49,04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
