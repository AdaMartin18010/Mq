# TC-CLU-RABBITMQ-FORCE-EXIT-01：RabbitMQ 节点强制退出

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点镜像队列

## When

- kill -9 1 node

## Then

- 镜像队列 master 迁移到存活节点
- 暂停/忽略少数派策略按 cluster_partition_handling 生效
- 恢复后 mirror 同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/rabbitmq/force-exit/TC-CLU-RABBITMQ-FORCE-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
