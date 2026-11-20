# TC-SCL-OSCPREVENT-DEADBAND-01：振荡防控 — 死区：lag 抖动 ±20% 内 KEDA 不动作

> **维度**：domain=SCL | subcat=OSCPREVENT | code=DEADBAND-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- lagThreshold=1000 / lag 在 900~1100 波动

## When

- 持续 5 分钟

## Then

- 副本数不变
- 控制动作次数=0
- 抖动被死区吸收

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-OSCPREVENT-DEADBAND-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
