# TC-SYN-RABBITMQ-CONFIRM-01：RABBITMQ publisher confirm vs 事务 运维行为测试

> **维度**：系统=RABBITMQ | 域=SYN（publisher confirm vs 事务）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 六系统语义能力对照 / §1.63.3 Kafka 事务（AMQP 工程类比）
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 同一队列分别用 publisher confirm 与 tx.select 发布持久化消息

## When

- broker 回传 ack/nack 或 tx.commit/rollback

## Then

- confirm 异步、轻量，保证消息到达队列（at-least-once），吞吐高于事务
- 事务模式批量原子提交/回滚，吞吐低但边界清晰
- 行为符合 01-63 RabbitMQ at-least-once / AMQP 事务范围

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/rabbitmq/TC-SYN-RABBITMQ-CONFIRM-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 六系统语义能力对照 / §1.63.3 Kafka 事务（AMQP 工程类比）；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
