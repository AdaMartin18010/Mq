# TC-CLU-PULSAR-FORCE-EXIT-01：Pulsar bookie 强制退出

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.7
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 bookie 集群 E3/WQ3/AQ2

## When

- kill -9 1 bookie

## Then

- 写仍可用（AQ=2）
- Auditor 标记 under-replicated ledgers
- AutoRecovery 复制数据到新 bookie

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-PULSAR-FORCE-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.7；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
