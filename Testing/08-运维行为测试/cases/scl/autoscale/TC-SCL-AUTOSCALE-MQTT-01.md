# TC-SCL-AUTOSCALE-MQTT-01：自动伸缩 — MQTT 自定义 lag 指标触发伸缩

> **维度**：domain=SCL | subcat=AUTOSCALE | code=MQTT-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- mosquitto exporter / custom metric

## When

- 设备洪峰

## Then

- 自定义 metrics 被 HPA 读取
- 副本数变化
- 连接数均衡

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-AUTOSCALE-MQTT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
