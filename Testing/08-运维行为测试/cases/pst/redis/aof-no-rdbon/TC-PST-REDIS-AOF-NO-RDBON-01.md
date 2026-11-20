# TC-PST-REDIS-AOF-NO-RDBON-01：AOF no + RDB 开启 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync no，save 启用 RDB

## When

- kill -9 redis-server 并重启

## Then

- 丢窗取决于 OS 刷盘节奏，可能 ≥1s（无 bounded 承诺）
- RDB 快照点之后写入可能全部丢失
- AOF 回滚至上次 fsync 点

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-REDIS-AOF-NO-RDBON-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
