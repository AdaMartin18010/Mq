# TC-SYN-RABBITMQ-MD5-01：RABBITMQ 副本内容一致性 运维行为测试

> **维度**：系统=RABBITMQ | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.3 Leader Epoch（Raft 类比）
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 镜像队列发布持久化消息集合

## When

- 从各 mirror 拉取消息

## Then

- 各 mirror 消息 payload md5 一致
- 队列深度一致（未 ack 除外）
- quorum 队列 RAFT log md5 摘要一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-RABBITMQ-MD5-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.3 Leader Epoch（Raft 类比）；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
