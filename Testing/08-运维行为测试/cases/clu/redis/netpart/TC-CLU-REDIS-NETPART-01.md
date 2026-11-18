# TC-CLU-REDIS-NETPART-01：Redis 哨兵 quorum 与分区

> **维度**：系统=REDIS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 sentinel + 1 master + 2 replica

## When

- 分区隔离 master 与多数 sentinel

## Then

- 只有 ≥quorum 的 sentinel 才能发起 failover
- minority sentinel 不会误晋升 replica
- 避免双主

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/redis/netpart/TC-CLU-REDIS-NETPART-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
