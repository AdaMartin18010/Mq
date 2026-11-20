# TC-SCL-OSCPREVENT-COLDSTART-01：振荡防控 — 冷启动雪崩：批量扩容同时拉全量快照

> **维度**：domain=SCL | subcat=OSCPREVENT | code=COLDSTART-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 一次性扩容 10 副本

## When

- 每个副本启动即全量恢复

## Then

- 消费端出现请求风暴/超时
- 后端存储压力峰值
- 记录雪崩

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-OSCPREVENT-COLDSTART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
