# TC-SCL-NODESCALE-RABBITMQ-01：节点伸缩 — RabbitMQ 集群节点加入与镜像队列再平衡

> **维度**：domain=SCL | subcat=NODESCALE | code=RABBITMQ-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-67,01-61
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 node cluster / HA queue

## When

- 新节点加入

## Then

- 新节点出现在 cluster_status
- 镜像队列副本重新分布
- policy ha-all 生效

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-RABBITMQ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-67,01-61；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
