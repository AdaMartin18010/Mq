# TC-SYN-RABBITMQ-LAG-01：RABBITMQ 复制滞后可观测 运维行为测试

> **维度**：系统=RABBITMQ | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.2 复制协议
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 镜像/quorum 队列持续发布

## When

- 副本同步落后

## Then

- mirror_sync_count / rabbitmq_queue_slave_pids 同步状态可观测
- quorum 队列 RAFT commit index diff ≤ 阈值
- 告警阈值：未同步消息数 > 1000 或 lag > 5s

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/rabbitmq/TC-SYN-RABBITMQ-LAG-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.2 复制协议；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
