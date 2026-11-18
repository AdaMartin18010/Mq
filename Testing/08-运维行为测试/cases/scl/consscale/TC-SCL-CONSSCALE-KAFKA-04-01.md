# TC-SCL-CONSSCALE-KAFKA-04-01：消费者伸缩 — Kafka static membership 减少重平衡震荡

> **维度**：domain=SCL | subcat=CONSSCALE | code=KAFKA-04 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-75
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 配置 group.instance.id

## When

- consumer 重启（member 不变）

## Then

- 重平衡不触发（静态成员）
- 消费继续
- 再加入时 offset 恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/consscale/TC-SCL-CONSSCALE-KAFKA-04-01.sh   # 计划打印（挂账）
```

## 关联

- 01-75；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
