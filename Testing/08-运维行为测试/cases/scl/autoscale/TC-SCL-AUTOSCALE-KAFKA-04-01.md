# TC-SCL-AUTOSCALE-KAFKA-04-01：自动伸缩 — HPA CPU 与 KEDA lag 双控制器不冲突

> **维度**：domain=SCL | subcat=AUTOSCALE | code=KAFKA-04 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- HPA 按 CPU / KEDA 按 lag

## When

- 并发压力

## Then

- 两控制器作用不同维度
- 无同时反向动作
- 副本数单调收敛

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-AUTOSCALE-KAFKA-04-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
