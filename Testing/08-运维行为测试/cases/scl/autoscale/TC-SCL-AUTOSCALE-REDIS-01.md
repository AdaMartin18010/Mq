# TC-SCL-AUTOSCALE-REDIS-01：自动伸缩 — Redis Stream XPENDING 触发扩容

> **维度**：domain=SCL | subcat=AUTOSCALE | code=REDIS-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 自定义 exporter / pending count

## When

- pending 增长

## Then

- consumer 扩容
- XPENDING 下降
- 消息处理不超时

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/autoscale/TC-SCL-AUTOSCALE-REDIS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
