# TC-SCL-OSCPREVENT-DEADBAND-02-01：振荡防控 — Prometheus deadband 抑制规则告警抖动

> **维度**：domain=SCL | subcat=OSCPREVENT | code=DEADBAND-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07,03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 告警规则 for=1m / 合成指标在阈值附近抖动

## When

- 观察 alertmanager

## Then

- 告警只触发一次
- 恢复后只解除一次
- 无 flapping 通知

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/oscprevent/TC-SCL-OSCPREVENT-DEADBAND-02-01.sh   # 计划打印（挂账）
```

## 关联

- 04-07,03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
