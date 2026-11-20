# TC-PST-KAFKA-ACK1-MIR1-01：acks=1/min.insync.replicas=1 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic RF=3，producer acks=1，min.insync.replicas=1

## When

- kill -9 leader 后立即重启

## Then

- 最多丢失 leader 已确认但尚未复制到 follower 的批次（≤1 个 in-flight batch）
- 未确认批次由客户端重试
- 恢复后 HW 不回流

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-KAFKA-ACK1-MIR1-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
