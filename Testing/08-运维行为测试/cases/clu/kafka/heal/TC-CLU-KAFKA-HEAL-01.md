# TC-CLU-KAFKA-HEAL-01：Kafka 分区愈合与 unclean.leader 风险

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2/1.61.3
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 分区隔离后恢复网络

## When

- 观察 leader epoch 与数据收敛

## Then

- ISR 重新扩展
- Leader Epoch 单调递增，避免日志分歧
- unclean.leader.election.enable=true 场景下可能出现数据丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-KAFKA-HEAL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2/1.61.3；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
