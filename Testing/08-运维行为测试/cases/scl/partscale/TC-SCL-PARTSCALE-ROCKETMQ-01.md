# TC-SCL-PARTSCALE-ROCKETMQ-01：分区伸缩 — RocketMQ topic 读写队列扩容

> **维度**：domain=SCL | subcat=PARTSCALE | code=ROCKETMQ-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,03-67
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 配置写队列数变更

## When

- 更新 perm + 队列数

## Then

- 新消息路由到新队列
- 消费进度按队列隔离
- namesrv 路由同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-PARTSCALE-ROCKETMQ-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61,03-67；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
