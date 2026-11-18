# TC-ALT-METRICCHK-REDIS-LAG-01：指标正确性 — Redis Stream consumer lag 指标对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=REDIS-LAG | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- XADD N 条 / 未 XREADGROUP

## When
- 对比 XPENDING 长度与自定义 exporter

## Then
- lag = pending 条目数
- consumer group 标签正确

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-REDIS-LAG-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
