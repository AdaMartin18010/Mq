# TC-SCL-OSCPREVENT-INTEGRAL-01：振荡防控 — 积分饱和：KEDA 长期误差 I 项限幅

> **维度**：domain=SCL | subcat=OSCPREVENT | code=INTEGRAL-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 模拟一周积压后 I 项巨大

## When

- 启用积分限幅

## Then

- 扩容幅度被限制
- 无一次性扩 10 倍
- 系统稳定

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/oscprevent/TC-SCL-OSCPREVENT-INTEGRAL-01.sh   # 计划打印（挂账）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
