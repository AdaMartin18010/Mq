# TC-SCL-CONSSCALE-RABBITMQ-01：消费者伸缩 — RabbitMQ 消费者增加时发布不中断

> **维度**：domain=SCL | subcat=CONSSCALE | code=RABBITMQ-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-68
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 队列有 1 consumer

## When

- consumer 扩到 3

## Then

- publisher 无阻塞
- round-robin 分发即时生效
- 队列长度下降

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-CONSSCALE-RABBITMQ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
