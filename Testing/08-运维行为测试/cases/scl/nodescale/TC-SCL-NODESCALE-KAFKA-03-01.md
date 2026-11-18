# TC-SCL-NODESCALE-KAFKA-03-01：节点伸缩 — Kafka 新 broker 成为 preferred leader

> **维度**：domain=SCL | subcat=NODESCALE | code=KAFKA-03 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- auto.leader.rebalance.enable=true

## When

- 等待 preferred leader 选举

## Then

- preferred leader 比例≥90%【估算】
- 生产切换无异常
- metadata 更新全客户端可见

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/nodescale/TC-SCL-NODESCALE-KAFKA-03-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
