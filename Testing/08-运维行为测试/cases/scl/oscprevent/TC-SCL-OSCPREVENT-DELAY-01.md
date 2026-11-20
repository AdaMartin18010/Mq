# TC-SCL-OSCPREVENT-DELAY-01：振荡防控 — 延迟振荡：采样周期 < 执行器响应时间

> **维度**：domain=SCL | subcat=OSCPREVENT | code=DELAY-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- pollingInterval=15s / 扩容生效 60s

## When

- 持续波动负载

## Then

- 观察到越扩越乱
- 调整 pollingInterval≥90s 后稳定
- 04-07 定理

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-OSCPREVENT-DELAY-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
