# TC-FAL-REDIS-MANUAL-01：REDIS 副本手动提升 REPLICAOF NO ONE 运维行为测试

> **维度**：系统=REDIS | 域=FAL（副本手动提升 REPLICAOF NO ONE）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 对 replica 执行 REPLICAOF NO ONE

## When
- 原 master 恢复后重新挂为 replica

## Then
- 新 master 可写，其余副本 REPLICAOF 指向新 master
- 脑裂防护：Sentinel 或人工脚本保证同时仅一个 master 可写；客户端配置切换
- 数据一致性：手动切换前已同步数据一致，切换后 offset 连续

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/redis/TC-FAL-REDIS-MANUAL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
