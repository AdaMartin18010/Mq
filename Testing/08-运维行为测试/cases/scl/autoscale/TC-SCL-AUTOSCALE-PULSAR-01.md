# TC-SCL-AUTOSCALE-PULSAR-01：自动伸缩 — KEDA Pulsar backlog 触发扩容

> **维度**：domain=SCL | subcat=AUTOSCALE | code=PULSAR-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- pulsar scaler / admin url / threshold

## When
- backlog 增长

## Then
- 副本数增加
- subscription backlog 下降
- 无重复消费

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/scl/autoscale/TC-SCL-AUTOSCALE-PULSAR-01.sh   # 计划打印（挂账）
```

## 关联
- 02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
