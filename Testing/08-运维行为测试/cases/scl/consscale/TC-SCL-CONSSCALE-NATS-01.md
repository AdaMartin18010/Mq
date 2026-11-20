# TC-SCL-CONSSCALE-NATS-01：消费者伸缩 — NATS queue group 1→3→1 分发重排

> **维度**：domain=SCL | subcat=CONSSCALE | code=NATS-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66,03-68
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- queue subject / 1 subscriber

## When

- queue group 扩缩

## Then

- 消息分发即时重排无中断
- 无重复投递（exactly-once queue）
- sub 退出时消息不丢

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-CONSSCALE-NATS-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66,03-68；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
