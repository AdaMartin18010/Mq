# TC-SCL-CONSSCALE-MQTT-01：消费者伸缩 — MQTT 共享订阅组 1→3→1

> **维度**：domain=SCL | subcat=CONSSCALE | code=MQTT-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-64
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- $share/group/topic / 1 subscriber

## When

- 共享订阅成员扩缩

## Then

- $share 分发重排无中断
- QoS1/2 消息按订阅者唯一交付
- 会话保持正确

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/consscale/TC-SCL-CONSSCALE-MQTT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
