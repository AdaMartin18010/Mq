# TC-CLU-REDIS-HEAL-01：Redis 旧主降为副本冲突解决

> **维度**：系统=REDIS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- failover 后旧 master 重新加入集群

## When

- 观察 configEpoch 与 slot 归属

## Then

- 旧 master 以 replica 身份加入
- 其数据被新 master 覆盖
- cluster 使用 configEpoch 解决冲突

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-REDIS-HEAL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
