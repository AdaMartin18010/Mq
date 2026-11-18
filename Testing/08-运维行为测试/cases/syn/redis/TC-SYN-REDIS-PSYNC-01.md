# TC-SYN-REDIS-PSYNC-01：REDIS 部分重同步 运维行为测试

> **维度**：系统=REDIS | 域=SYN（部分重同步）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- replica 与 master 建立复制后断开

## When

- 在 repl_backlog 范围内 reconnect

## Then

- offset 仍在 backlog 内时触发 partial resync
- offset 落后过多触发 full sync
- 切换后 replication offset 连续

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/redis/TC-SYN-REDIS-PSYNC-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
