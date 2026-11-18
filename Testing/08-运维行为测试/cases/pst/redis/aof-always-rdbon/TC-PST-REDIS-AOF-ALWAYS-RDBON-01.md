# TC-PST-REDIS-AOF-ALWAYS-RDBON-01：AOF always + RDB 开启 kill -9

> **维度**：系统=REDIS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67 §持久化
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- appendonly yes，appendfsync always，save 启用 RDB

## When

- kill -9 redis-server 并重启

## Then

- 每条写入 fsync，kill -9 后最多丢失当前正在执行的命令（≤1 条）
- AOF 重放后数据一致
- RDB 存在但 AOF 优先加载

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/redis/aof-always-rdbon/TC-PST-REDIS-AOF-ALWAYS-RDBON-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67 §持久化；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
