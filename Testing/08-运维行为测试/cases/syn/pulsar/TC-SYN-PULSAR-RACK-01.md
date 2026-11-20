# TC-SYN-PULSAR-RACK-01：PULSAR bookie 机架感知 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（bookie 机架感知）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 Ensemble Placement / §1.62.7 故障推演
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- bookies 分布在 2+ racks，启用 ensemble placement policy

## When

- bookie 故障

## Then

- 新 ensemble 跨 fault domain 选择 bookie
- 同一 ledger WQ 副本不集中在单 rack
- 故障域隔离保证 AQ 可用

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-PULSAR-RACK-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.2 Ensemble Placement / §1.62.7 故障推演；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
