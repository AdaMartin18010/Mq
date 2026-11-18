# TC-PST-KAFKA-ACK0-MIR2-01：acks=0/min.insync.replicas=2 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker KRaft，topic RF=3，producer acks=0，min.insync.replicas=2

## When

- kill -9 任意 broker

## Then

- acks=0 不等待任何确认，丢窗仍无界
- min.insync.replicas=2 仅影响 acks=all 语义，对 acks=0 不生效
- 恢复后校验 log-dump 段连续

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/kafka/ack0-mir2/TC-PST-KAFKA-ACK0-MIR2-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
