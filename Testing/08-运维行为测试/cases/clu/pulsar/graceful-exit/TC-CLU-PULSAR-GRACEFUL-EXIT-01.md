# TC-CLU-PULSAR-GRACEFUL-EXIT-01：Pulsar bookie 优雅退役

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.6
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 4 bookie 集群

## When

- bookkeeper shell decommissionbookie

## Then

- 该 bookie 上 ledgers 复制到其他节点
- decommission 完成后可安全下线
- underReplicatedLedgers 最终为 0

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-PULSAR-GRACEFUL-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.6；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
