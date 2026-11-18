# TC-SYN-ROCKETMQ-SYNC-01：ROCKETMQ sync vs async 主从复制 运维行为测试

> **维度**：系统=ROCKETMQ | 域=SYN（sync vs async 主从复制）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RocketMQ 语义对照【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 主从 sync_master / async_master 配置

## When

- producer 发送后 broker 返回 ack

## Then

- sync_master：等待 slave 同步后才 ack；async_master：master 落盘即 ack
- sync 延迟高但丢数据风险低
- 行为符合 01-63 RocketMQ at-least-once 语义【论证】

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/rocketmq/TC-SYN-ROCKETMQ-SYNC-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 RocketMQ 语义对照【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
