# TC-ALT-ALERTRULE-INHIBIT-01：告警规则正确性 — 告警风暴 inhibit 去重

> **维度**：domain=ALT | subcat=ALERTRULE | code=INHIBIT | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：topics/config-templates/prometheus-alert-rules.yml,03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 同时触发 KafkaOfflinePartitions + KafkaUnderReplicated

## When

- 配置 inhibit 规则：p0 抑制 p1

## Then

- 只收到 p0 通知
- p1 被抑制不重复通知
- inhibit 日志可审计

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-ALERTRULE-INHIBIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- topics/config-templates/prometheus-alert-rules.yml,03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
