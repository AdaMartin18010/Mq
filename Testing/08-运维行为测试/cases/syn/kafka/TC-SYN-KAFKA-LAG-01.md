# TC-SYN-KAFKA-LAG-01：KAFKA 复制滞后可观测 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR / §1.61.7 副本落后恢复
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 恒定速率生产，RF=3

## When

- follower 落后达到阈值

## Then

- UnderReplicatedPartitions / ReplicaFetcherLag 指标可采集
- lag 告警阈值 ≤ replica.lag.time.max.ms；超出则 ISR 收缩
- 恢复后 IsrExpandsPerSec 触发，lag 归零

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-KAFKA-LAG-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2 ISR / §1.61.7 副本落后恢复；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
