# TC-PST-KAFKA-ACK1-MIR2-01：acks=1/min.insync.replicas=2 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2/1.61.3
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic RF=3，producer acks=1，min.insync.replicas=2

## When

- kill -9 leader

## Then

- acks=1 仍只等 leader ACK；丢窗同 ACK1-MIR1（≤1 in-flight batch）
- min.insync.replicas=2 不改变 acks=1 语义，但降低 acks=all 可用阈值
- 旧 leader 恢复后按 Leader Epoch 截断，避免数据分歧

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/kafka/ack1-mir2/TC-PST-KAFKA-ACK1-MIR2-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2/1.61.3；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
