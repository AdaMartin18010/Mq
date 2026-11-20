# TC-SCL-AUTOSCALE-RABBITMQ-01：自动伸缩 — KEDA RabbitMQ queue length 触发扩容

> **维度**：domain=SCL | subcat=AUTOSCALE | code=RABBITMQ-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：02-49
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- rabbitmq scaler / queueName / lengthThreshold

## When

- 队列填充

## Then

- 副本数增加
- 队列长度下降
- 无死信风暴

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-AUTOSCALE-RABBITMQ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 02-49；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
