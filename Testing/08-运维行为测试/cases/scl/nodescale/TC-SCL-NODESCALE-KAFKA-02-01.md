# TC-SCL-NODESCALE-KAFKA-02-01：节点伸缩 — Kafka 新 broker 接管分区迁移进度指标

> **维度**：domain=SCL | subcat=NODESCALE | code=KAFKA-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 持续监控 JMX

## When

- 观察 ReplicaFetcherManager

## Then

- kafka_server_replicamanager_underreplicatedpartitions 收敛
- bytes in/out 均衡度改善
- 无 leader 长时间悬挂

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-KAFKA-02-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
