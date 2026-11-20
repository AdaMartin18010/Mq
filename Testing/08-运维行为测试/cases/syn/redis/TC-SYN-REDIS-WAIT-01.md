# TC-SYN-REDIS-WAIT-01：REDIS WAIT 命令同步复制 运维行为测试

> **维度**：系统=REDIS | 域=SYN（WAIT 命令同步复制）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- Redis 主从，producer 写后执行 WAIT numreplicas timeout

## When

- 同步复制等待

## Then

- WAIT 返回前至少 N 个副本确认，否则返回实际同步副本数
- 提供同步复制点，但非事务
- 行为符合 01-63 at-least-once 强化

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-REDIS-WAIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
