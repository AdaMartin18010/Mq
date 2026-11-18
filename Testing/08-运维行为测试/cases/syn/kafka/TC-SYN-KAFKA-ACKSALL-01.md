# TC-SYN-KAFKA-ACKSALL-01：KAFKA acks=all 行为 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（acks=all 行为）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR/min.insync.replicas / 01-63 §1.63.2 幂等生产者
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer acks=all, min.insync.replicas=2, RF=3

## When

- 发送并 kill 一个 follower

## Then

- 只要 ISR≥2，写入成功；已 ack 消息在 ISR 内完整
- acks=all 提供最强持久化承诺
- 行为符合 01-63 exactly-once 系统级基石

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/kafka/TC-SYN-KAFKA-ACKSALL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2 ISR/min.insync.replicas / 01-63 §1.63.2 幂等生产者；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
