# TC-SYN-KAFKA-ACKS1-01：KAFKA acks=1 行为 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（acks=1 行为）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 LEO/HW / 01-63 §1.63.1
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer acks=1

## When

- leader 返回 ack 后宕机

## Then

- 已 ack 消息若未复制到 follower，leader 宕机后可能丢失（at-least-once 边界）
- 消费者可读到 HW 前消息；未同步消息存在丢风险
- 行为符合 01-63 at-least-once 定义

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-KAFKA-ACKS1-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2 LEO/HW / 01-63 §1.63.1；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
