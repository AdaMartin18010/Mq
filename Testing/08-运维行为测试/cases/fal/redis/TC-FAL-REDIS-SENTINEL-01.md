# TC-FAL-REDIS-SENTINEL-01：REDIS 哨兵 failover 运维行为测试

> **维度**：系统=REDIS | 域=FAL（哨兵 failover）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照 / §1.63.1 交付语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- Redis 一主两从 + Sentinel×3，kill master

## When
- sentinel 自动 promote replica

## Then
- sentinel 达成 quorum 后切换，RTO≤10s【估算】
- 已写数据在 AOF everysec 模式下丢失窗口≤1s（声明边界）
- 脑裂防护：sentinel quorum + min-replicas-to-write；分区 minority 主库降级只读
- 数据一致性：新主库 keys 与旧主一致，replicas 重新 psync

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/redis/TC-FAL-REDIS-SENTINEL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 §1.63.7 Redis Stream 语义对照 / §1.63.1 交付语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
