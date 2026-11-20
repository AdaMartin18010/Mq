# TC-PST-KAFKA-UNCLEAN-LEADER-01：unclean.leader.election.enable 持久化风险

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- topic RF=3，acks=all，min.insync.replicas=2；分别设置 unclean.leader.election.enable=true/false

## When

- leader 与全部 ISR 同时崩溃，落后副本成为唯一存活副本

## Then

- false 时分区不可用，已提交数据不丢
- true 时落后副本晋升 leader，可能丢失已确认消息
- 丢窗=leader 崩溃前已 ack 但落后副本未复制的数据

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-KAFKA-UNCLEAN-LEADER-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
