# TC-PST-RABBITMQ-QUORUM-QUEUE-01：RabbitMQ Quorum Queue 重启持久化

> **维度**：系统=RABBITMQ | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 声明 quorum queue，发布 persistent 消息

## When

- kill -9 任意 2 节点后恢复

## Then

- quorum queue 基于 Raft，多数派节点存活即可恢复
- 已 confirm 消息不丢
- 丢窗≤未确认消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-RABBITMQ-QUORUM-QUEUE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-65；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
