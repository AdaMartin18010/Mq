# TC-PST-REDIS-RDB-ONLY-01：RDB-only 持久化 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- save 启用 RDB，appendonly no

## When

- kill -9 redis-server 并重启

## Then

- 丢窗≤自上次 RDB save 以来的写入
- 恢复后加载最近 .rdb
- 无 AOF 时无法 finer-grained 回滚

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-REDIS-RDB-ONLY-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
