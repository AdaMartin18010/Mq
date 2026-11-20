# TC-PST-REDIS-AOF-ALWAYS-RDBOFF-01：AOF always + RDB 关闭 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync always，save 空

## When

- kill -9 redis-server 并重启

## Then

- 丢窗≤1 条
- 无 RDB 回退，完全依赖 AOF
- AOF 文件完整可重放

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-REDIS-AOF-ALWAYS-RDBOFF-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
