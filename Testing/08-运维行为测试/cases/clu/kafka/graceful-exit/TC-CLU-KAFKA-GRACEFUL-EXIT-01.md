# TC-CLU-KAFKA-GRACEFUL-EXIT-01：Kafka broker 优雅退役

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 4 broker 集群，topic RF=3

## When

- kafka-reassign-partitions 迁出数据后关闭 broker

## Then

- 该 broker 上无 leader 分区
- 分区副本已全部迁移
- 关闭过程无 Unclean Leader

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/kafka/graceful-exit/TC-CLU-KAFKA-GRACEFUL-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
