# TC-PST-KAFKA-ACKALL-MIR2-01：acks=all/min.insync.replicas=2 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic RF=3，producer acks=all，min.insync.replicas=2

## When

- kill leader

## Then

- 已 ack 消息至少被 2 个 ISR 确认，单点故障不丢
- 若第二 ISR 同时崩溃，分区不可用（但已提交数据仍在存活副本）
- 恢复后 ISR 追赶，HW 单调递增

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-KAFKA-ACKALL-MIR2-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
