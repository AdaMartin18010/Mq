# TC-SCL-PARTSCALE-PULSAR-01：分区伸缩 — Pulsar bundle split 期间生产不中断

> **维度**：domain=SCL | subcat=PARTSCALE | code=PULSAR-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62,02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace 高流量 topic

## When

- pulsar-admin namespaces split-bundle

## Then

- split 期间 broker 不丢写
- bundle 边界可观测（topic 归属）
- 加载到新 broker 后 backlog 一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/partscale/TC-SCL-PARTSCALE-PULSAR-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62,02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
