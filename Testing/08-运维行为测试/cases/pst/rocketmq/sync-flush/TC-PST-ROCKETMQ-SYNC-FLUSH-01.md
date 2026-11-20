# TC-PST-ROCKETMQ-SYNC-FLUSH-01：RocketMQ SYNC_FLUSH 断电丢窗

> **维度**：系统=ROCKETMQ | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker flushDiskType=SYNC_FLUSH

## When

- kill -9 broker 模拟断电

## Then

- 消息刷盘后才返回 SEND_OK，丢窗≤0（已确认消息）
- 未确认消息可能丢失
- 恢复后 commitlog 校验

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-ROCKETMQ-SYNC-FLUSH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
