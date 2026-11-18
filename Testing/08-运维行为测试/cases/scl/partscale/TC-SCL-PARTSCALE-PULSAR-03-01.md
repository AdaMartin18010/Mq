# TC-SCL-PARTSCALE-PULSAR-03-01：分区伸缩 — Pulsar split + unload 组合流量下正确性

> **维度**：domain=SCL | subcat=PARTSCALE | code=PULSAR-03 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 持续生产+消费

## When

- split 后立即 unload

## Then

- 无重复消费（dedup 保证）
- 无消息丢失
- bundle 元数据一致性

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/partscale/TC-SCL-PARTSCALE-PULSAR-03-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
