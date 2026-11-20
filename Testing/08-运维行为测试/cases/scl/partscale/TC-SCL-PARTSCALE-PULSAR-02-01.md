# TC-SCL-PARTSCALE-PULSAR-02-01：分区伸缩 — Pulsar bundle unload 负载再平衡

> **维度**：domain=SCL | subcat=PARTSCALE | code=PULSAR-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 负载不均

## When

- pulsar-admin namespaces unload

## Then

- unload 窗口≤秒级
- 客户端重连到新 broker 成功
- topic 统计无跳跃

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-PARTSCALE-PULSAR-02-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
