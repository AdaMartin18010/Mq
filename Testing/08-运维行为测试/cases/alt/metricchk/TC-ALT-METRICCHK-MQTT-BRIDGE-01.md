# TC-ALT-METRICCHK-MQTT-BRIDGE-01：指标正确性 — MQTT 桥接指标与 mosquitto 状态对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=MQTT-BRIDGE | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-64,03-63
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 桥接发布 N 条

## When
- 对比 bridge metrics 与实际

## Then
- 桥接连接状态一致
- 消息计数一致

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/alt/metricchk/TC-ALT-METRICCHK-MQTT-BRIDGE-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64,03-63；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
