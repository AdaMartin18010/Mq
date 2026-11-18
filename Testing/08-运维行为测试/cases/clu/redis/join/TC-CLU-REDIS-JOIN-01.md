# TC-CLU-REDIS-JOIN-01：Redis Cluster meet 组建

> **维度**：系统=REDIS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 6 节点（3 主 3 从）

## When

- redis-cli --cluster create

## Then

- cluster nodes 显示 16384 slots 全部分配
- 每个 master 至少 1 replica
- cluster_state=ok

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/redis/join/TC-CLU-REDIS-JOIN-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
