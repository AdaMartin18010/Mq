# TC-SCL-CONSSCALE-KAFKA-01：消费者伸缩 — Kafka 消费组 1→3 成员变化重平衡时长

> **维度**：domain=SCL | subcat=CONSSCALE | code=KAFKA-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-75,08-运维行为测试
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic 6 partition / 1 consumer

## When

- 启动到 3 consumers

## Then

- 重平衡完成时间≤30s【估算】
- partition 分配均衡
- 消费继续

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/consscale/TC-SCL-CONSSCALE-KAFKA-01.sh   # 计划打印（挂账）
```

## 关联

- 01-75,08-运维行为测试；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
