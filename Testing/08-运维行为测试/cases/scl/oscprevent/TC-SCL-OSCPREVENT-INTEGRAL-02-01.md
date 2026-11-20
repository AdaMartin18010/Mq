# TC-SCL-OSCPREVENT-INTEGRAL-02-01：振荡防控 — 分段重置：backlog 周级别回落后 I 项清零

> **维度**：domain=SCL | subcat=OSCPREVENT | code=INTEGRAL-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- backlog 从高位回落

## When

- 触发 anti-windup 重置

## Then

- I 项归零
- 缩容按保守策略执行
- 无超调

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-OSCPREVENT-INTEGRAL-02-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
