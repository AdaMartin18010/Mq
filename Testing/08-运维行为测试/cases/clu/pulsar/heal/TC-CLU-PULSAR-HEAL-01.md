# TC-CLU-PULSAR-HEAL-01：Pulsar 分区愈合后 ledger 复制收敛

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.7
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- bookie 分区恢复

## When

- 检查 under-replicated ledgers

## Then

- Auditor/AutoRecovery 补齐副本
- underReplicatedLedgers 降至 0
- 读写恢复正常

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-PULSAR-HEAL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.7；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
