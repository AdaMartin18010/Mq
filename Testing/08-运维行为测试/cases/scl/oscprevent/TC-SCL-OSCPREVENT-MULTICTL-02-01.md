# TC-SCL-OSCPREVENT-MULTICTL-02-01：振荡防控 — 分维度控制器稳定：CPU vs lag 双维度

> **维度**：domain=SCL | subcat=OSCPREVENT | code=MULTICTL-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- HPA CPU / KEDA lag 不同阈值

## When

- 复合压力

## Then

- 两控制器各自按维度动作
- 无振荡
- 最终 SLO 恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/oscprevent/TC-SCL-OSCPREVENT-MULTICTL-02-01.sh   # 计划打印（挂账）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
