# TC-SYN-REDIS-LAG-01：REDIS 复制滞后可观测 运维行为测试

> **维度**：系统=REDIS | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 主从持续写入

## When

- replica 落后

## Then

- INFO replication：master_repl_offset - slave_repl_offset 计算 lag
- 告警阈值：lag 字节 > 1MB 或 slave 状态 stale
- 慢 replica 触发 client output buffer 限制可观测

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/redis/TC-SYN-REDIS-LAG-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
