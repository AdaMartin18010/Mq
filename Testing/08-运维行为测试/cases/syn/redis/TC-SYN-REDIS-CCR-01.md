# TC-SYN-REDIS-CCR-01：REDIS 跨主从复制断连恢复 运维行为测试

> **维度**：系统=REDIS | 域=SYN（跨主从复制断连恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- replicaof 指向远端 master

## When

- 复制链路断开再恢复

## Then

- 断连期间 master backlog 保留；reconnect 后优先 partial resync
- backlog 不足时触发 full sync
- 数据一致性：PSYNC 后 key 集合一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-REDIS-CCR-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
