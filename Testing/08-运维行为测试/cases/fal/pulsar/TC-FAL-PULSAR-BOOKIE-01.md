# TC-FAL-PULSAR-BOOKIE-01：PULSAR bookie 失效→ledger 恢复 运维行为测试

> **维度**：系统=PULSAR | 域=FAL（bookie 失效→ledger 恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 读写可用性矩阵
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 停止一个 bookie（E=3, WQ=3, AQ=2）

## When
- Auditor/AutoRecovery 触发 ledger 恢复

## Then
- 写入仍可用（AQ=2 满足），后续 entry ensemble 替换为新 bookie
- underReplicatedLedgers 在恢复完成后归零
- 脑裂防护：ledger ensemble 元数据由 metadata quorum 维护；单 bookie 不会导致双主
- 数据一致性：AutoRecovery 从存活副本复制缺失 entry，entry 校验和通过

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/pulsar/TC-FAL-PULSAR-BOOKIE-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 读写可用性矩阵；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
