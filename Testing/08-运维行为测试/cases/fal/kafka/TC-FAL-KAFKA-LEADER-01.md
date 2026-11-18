# TC-FAL-KAFKA-LEADER-01：KAFKA leader 选举 运维行为测试

> **维度**：系统=KAFKA | 域=FAL（leader 选举）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- RF=3 分区，识别当前 leader broker 并 kill -9

## When

- 持续生产 acks=all，RTO 计时

## Then

- ISR 在 replica.lag.time.max.ms + controller 通知周期内完成重选，RTO≤30s【估算】
- 已 ack 消息 offset 连续，leader-epoch-checkpoint 单调递增
- 脑裂防护：非 ISR 副本因 unclean.leader.election.enable=false 无法竞选；min.insync.replicas=2 保证分区 minority 侧不可写
- 数据一致性：新 leader HW 不小于原 leader 崩溃前已提交 HW

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/fal/kafka/TC-FAL-KAFKA-LEADER-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
