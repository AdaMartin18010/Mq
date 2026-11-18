# TC-PST-REDIS-AOF-EVERYSEC-RDBON-01：AOF everysec + RDB 开启 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67 §持久化/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync everysec，save 启用 RDB

## When

- kill -9 redis-server 并重启

## Then

- 丢窗≤1s（everysec 刷盘间隔）【估算】
- AOF rewrite 期间写入通过 Copy-on-Write 不阻塞
- RDB 提供最近一次快照回退

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/redis/aof-everysec-rdbon/TC-PST-REDIS-AOF-EVERYSEC-RDBON-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67 §持久化/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
