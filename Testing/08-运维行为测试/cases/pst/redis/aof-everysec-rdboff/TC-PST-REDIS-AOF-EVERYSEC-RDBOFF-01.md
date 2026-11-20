# TC-PST-REDIS-AOF-EVERYSEC-RDBOFF-01：AOF everysec + RDB 关闭 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync everysec，save 空

## When

- kill -9 redis-server 并重启

## Then

- 丢窗≤1s
- AOF 文件可重放至最近 fsync
- RDB 关闭后恢复时间可能较长

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-REDIS-AOF-EVERYSEC-RDBOFF-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
