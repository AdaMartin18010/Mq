# TC-CLU-KAFKA-FORCE-EXIT-01：Kafka broker 强制退出

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.7
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 4 broker 集群，topic RF=3

## When

- kill -9 1 broker

## Then

- Controller 将该 broker 上分区标记 under-replicated
- ISR 收缩至剩余副本
- 恢复后追赶再入 ISR

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-KAFKA-FORCE-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.7；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
