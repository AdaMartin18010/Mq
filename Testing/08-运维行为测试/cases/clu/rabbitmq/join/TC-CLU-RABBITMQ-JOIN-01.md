# TC-CLU-RABBITMQ-JOIN-01：RabbitMQ 集群 join 与镜像策略

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 RabbitMQ，rabbitmqctl join_cluster

## When

- 启用 ha-all 镜像策略

## Then

- cluster_status 显示 3 running nodes
- 队列在多个节点上存在 master+mirror
- 策略生效后新建队列自动镜像

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/rabbitmq/join/TC-CLU-RABBITMQ-JOIN-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
