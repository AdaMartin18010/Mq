# TC-ALT-METRICCHK-REDIS-MEM-01：指标正确性 — Redis 内存指标与 INFO memory 对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=REDIS-MEM | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 写入数据集

## When

- 对比 redis_memory_used_bytes 与 INFO memory used

## Then

- 差值=0
- maxmemory 边界一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-METRICCHK-REDIS-MEM-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
