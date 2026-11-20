# TC-CLU-REDIS-REPLACE-01：Redis Cluster 节点替换

> **维度**：系统=REDIS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 主 3 从，标记一主为 fail

## When

- CLUSTER FORGET 旧节点并加入新节点作为 replica

## Then

- 新节点被分配为某主 replica
- 数据从 master 同步
- cluster 最终状态稳定，slots 无遗漏

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-REDIS-REPLACE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
