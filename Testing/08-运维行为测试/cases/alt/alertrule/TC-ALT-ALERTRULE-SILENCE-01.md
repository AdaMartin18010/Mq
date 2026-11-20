# TC-ALT-ALERTRULE-SILENCE-01：告警规则正确性 — Alertmanager silence 临时屏蔽告警

> **维度**：domain=ALT | subcat=ALERTRULE | code=SILENCE | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- KafkaConsumerLagHigh 持续 firing

## When

- 创建 silence matcher

## Then

- silence 期间通知停止
- silence 过期后通知恢复
- silence 元数据可审计

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/alertrule/TC-ALT-ALERTRULE-SILENCE-01.sh   # 计划打印（挂账）
```

## 关联

- 03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
