# TC-PST-KAFKA-ACK0-MIR1-01：acks=0/min.insync.replicas=1 持久化阶梯

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR/HW/acks 语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker KRaft，topic RF=3，producer acks=0，min.insync.replicas=1

## When

- kill -9 leader broker，持续生产

## Then

- producer 无 ACK 等待，leader 切换期间丢窗无界（最多为未消费/未重放段）
- 已发送但未落盘消息可能丢失
- 恢复后分区继续服务，但不承诺任何已发消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-KAFKA-ACK0-MIR1-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2 ISR/HW/acks 语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
