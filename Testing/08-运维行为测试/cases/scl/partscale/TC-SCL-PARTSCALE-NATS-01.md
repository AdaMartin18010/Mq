# TC-SCL-PARTSCALE-NATS-01：分区伸缩 — NATS JetStream stream 分区（subject 映射）扩展

> **维度**：domain=SCL | subcat=PARTSCALE | code=NATS-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- R1 stream / 持续发布

## When

- 更新 stream subjects

## Then

- 新 subject 消息进入同一 stream
- consumer filter 即时生效
- sequence 连续

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/partscale/TC-SCL-PARTSCALE-NATS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
