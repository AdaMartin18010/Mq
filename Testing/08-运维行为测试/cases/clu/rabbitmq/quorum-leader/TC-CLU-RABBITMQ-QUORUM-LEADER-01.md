# TC-CLU-RABBITMQ-QUORUM-LEADER-01：RabbitMQ Quorum Queue leader 选举

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 quorum queue

## When

- kill leader node

## Then

- 剩余 follower 基于 Raft 选出新 leader
- 已 confirm 消息可继续消费
- 旧 leader 恢复后以 follower 加入并同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/rabbitmq/quorum-leader/TC-CLU-RABBITMQ-QUORUM-LEADER-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
