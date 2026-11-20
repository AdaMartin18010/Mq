# TC-SCL-CONSSCALE-PULSAR-01：消费者伸缩 — Pulsar 消费者增加时生产不中断

> **维度**：domain=SCL | subcat=CONSSCALE | code=PULSAR-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 1 consumer subscription

## When

- consumer 扩到 3

## Then

- 无 ack 超时
- key_shared 下同一 key 仍到同一 consumer
- 吞吐上升

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-CONSSCALE-PULSAR-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
