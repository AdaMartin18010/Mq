# TC-SCL-NODESCALE-ROCKETMQ-01：节点伸缩 — RocketMQ broker 注册 namesrv 收敛

> **维度**：domain=SCL | subcat=NODESCALE | code=ROCKETMQ-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 持续生产

## When

- 新 broker 启动

## Then

- namesrv 路由表新增 broker
- producer 更新路由
- 消费无中断

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-ROCKETMQ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
