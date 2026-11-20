# TC-SCL-CONSSCALE-KAFKA-03-01：消费者伸缩 — Kafka 重平衡期间生产不中断

> **维度**：domain=SCL | subcat=CONSSCALE | code=KAFKA-03 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-75,TC-OPS-KAFKA-REBALPRODUCE-01
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 持续 producer

## When

- 消费组 1→3→1

## Then

- producer send() 无超时
- 已 ack 消息不丢
- 重平衡次数=2

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-CONSSCALE-KAFKA-03-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-75,TC-OPS-KAFKA-REBALPRODUCE-01；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
