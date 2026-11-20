# TC-SYN-PULSAR-LAG-01：PULSAR 复制滞后可观测 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 故障推演
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- bookie 写入持续负载

## When

- ledger 复制落后

## Then

- pulsar_storage_write_latency / managedLedgerCursorBacklog 可采集
- bookkeeper SERVER_WRITE_ENTRY / underReplicatedLedgers 告警
- 告警阈值：cursor backlog > 10k 或 under-replicated ledger 数 > 0 持续 60s

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-PULSAR-LAG-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 故障推演；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
