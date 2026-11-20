# TC-CLU-RABBITMQ-NETPART-01：RabbitMQ pause_minority 行为

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点集群，cluster_partition_handling=pause_minority

## When

- 分区产生 1 vs 2

## Then

- 少数派（1 节点）暂停应用
- 多数派继续服务
- 恢复后 minority 恢复并同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-RABBITMQ-NETPART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-65/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
