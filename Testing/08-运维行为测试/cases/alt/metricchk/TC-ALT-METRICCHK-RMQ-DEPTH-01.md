# TC-ALT-METRICCHK-RMQ-DEPTH-01：指标正确性 — RabbitMQ prometheus 插件队列深度对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=RMQ-DEPTH | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 队列有 N 条 ready

## When

- 对比 rabbitmq_queue_messages_ready 与 rabbitmqctl list_queues

## Then

- 差值=0
- 队列标签正确
- 无镜像重复计数

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-METRICCHK-RMQ-DEPTH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
