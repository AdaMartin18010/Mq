# TC-PST-REDIS-AOF-REWRITE-01：AOF rewrite 期间持续写入

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync everysec，触发 BGREWRITEAOF

## When

- kill -9 在 rewrite 过程中

## Then

- rewrite 不阻塞写入，子进程写新 AOF，父进程继续服务
- kill -9 后 Redis 选择完整旧 AOF 或新 AOF（若完成）
- 丢窗≤1s，rewrite 期间无额外丢窗

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-REDIS-AOF-REWRITE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
