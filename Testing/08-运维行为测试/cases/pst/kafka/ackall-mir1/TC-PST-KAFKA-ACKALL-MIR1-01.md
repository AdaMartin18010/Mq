# TC-PST-KAFKA-ACKALL-MIR1-01：acks=all/min.insync.replicas=1 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic RF=3，producer acks=all，min.insync.replicas=1

## When

- kill leader 与 1 follower 同时（仅剩 1 ISR）

## Then

- 已 ack 消息在至少 1 个 ISR 上完成 fsync/页缓存，不丢
- 分区因无足够 ISR 进入不可用，直至旧 leader 或 follower 恢复
- unclean.leader.election.enable=false 时不选非 ISR 副本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/kafka/ackall-mir1/TC-PST-KAFKA-ACKALL-MIR1-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
