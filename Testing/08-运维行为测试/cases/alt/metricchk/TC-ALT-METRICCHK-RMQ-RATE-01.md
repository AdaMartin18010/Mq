# TC-ALT-METRICCHK-RMQ-RATE-01：指标正确性 — RabbitMQ publish rate 指标对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=RMQ-RATE | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 固定速率 publish

## When

- 对比 rabbitmq_channel_messages_published_total 与客户端计数

## Then

- 差值<5%【估算】
- 时间窗口对齐

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-RMQ-RATE-01.sh   # 计划打印（挂账）
```

## 关联

- 03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
