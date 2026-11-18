# TC-SCL-CONSSCALE-KAFKA-02-01：消费者伸缩 — Kafka 消费组 3→1 成员变化重平衡时长

> **维度**：domain=SCL | subcat=CONSSCALE | code=KAFKA-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-75
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 consumers 稳定消费

## When

- 停掉 2 consumers

## Then

- 重平衡完成时间≤30s【估算】
- 剩余 consumer 接管全部分区
- 无重复消费（stable）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/consscale/TC-SCL-CONSSCALE-KAFKA-02-01.sh   # 计划打印（挂账）
```

## 关联

- 01-75；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
