# TC-SCL-OSCPREVENT-MULTICTL-01：振荡防控 — 多控制器冲突：HPA 与 KEDA 同指标 lag 同时动作

> **维度**：domain=SCL | subcat=OSCPREVENT | code=MULTICTL-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- HPA 按 lag / KEDA 也按 lag

## When

- lag 上升

## Then

- 观察到副本数抖动或超调
- 记录冲突
- 改为单指标单控制器后稳定

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/oscprevent/TC-SCL-OSCPREVENT-MULTICTL-01.sh   # 计划打印（挂账）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
