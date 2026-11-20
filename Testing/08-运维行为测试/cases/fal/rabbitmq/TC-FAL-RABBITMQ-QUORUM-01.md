# TC-FAL-RABBITMQ-QUORUM-01：RABBITMQ quorum 队列 leader 转移 运维行为测试

> **维度**：系统=RABBITMQ | 域=FAL（quorum 队列 leader 转移）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.3 Leader Epoch（Raft 工程类比）/ 01-63 §1.63.7 RabbitMQ 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 3 节点 quorum queue，stop leader 成员容器

## When
- 持续发布 + 消费

## Then
- 剩余成员在 Raft 选举超时内选出新 leader，RTO≤10s【估算】
- 已 publisher-confirm 的消息不丢，队列深度一致
- 脑裂防护：quorum queue Raft 多数派；minority 成员拒绝服务
- 数据一致性：Raft log term/index 单调，无日志分歧

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-RABBITMQ-QUORUM-01   # 计划打印（dry-run RC=0）
```

## 关联
- 01-61 §1.61.3 Leader Epoch（Raft 工程类比）/ 01-63 §1.63.7 RabbitMQ 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
