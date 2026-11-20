# TC-CLU-KAFKA-NETPART-01：Kafka 最小 ISR 失守分区不可用

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker，topic RF=3，acks=all，min.insync.replicas=2

## When

- 网络分区隔离 leader 与 1 follower

## Then

- 满足 acks=all 的 ISR 不足，分区停止写入
- 消费者仍可读至旧 HW
- unclean.leader.election.enable=false 防止非 ISR 晋升

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-KAFKA-NETPART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
