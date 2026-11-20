# TC-ALT-ALERTRULE-RMQ-BACKLOG-01：告警规则正确性 — RabbitMQQueueBacklog 触发与解除

> **维度**：domain=ALT | subcat=ALERTRULE | code=RMQ-BACKLOG | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：topics/config-templates/prometheus-alert-rules.yml
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 合成 queue_messages_ready=60000

## When

- 持续 15m 后 0

## Then

- 15m 后告警 firing
- 消费后 resolved

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/alertrule/TC-ALT-ALERTRULE-RMQ-BACKLOG-01.sh   # 计划打印（挂账）
```

## 关联

- topics/config-templates/prometheus-alert-rules.yml；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
