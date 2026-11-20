# TC-SCL-AUTOSCALE-KAFKA-05-01：自动伸缩 — KEDA scale to zero 空闲消费者

> **维度**：domain=SCL | subcat=AUTOSCALE | code=KAFKA-05 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- idleReplicaCount=0 / 无 lag

## When

- 等待 idle

## Then

- 副本数降到 0
- 新 lag 到来后恢复
- 恢复时间可接受

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-AUTOSCALE-KAFKA-05-01   # 计划打印（dry-run RC=0）
```

## 关联

- 02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
