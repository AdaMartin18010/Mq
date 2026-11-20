# TC-SYN-NATS-ACKPOLICY-01：NATS consumer ack 策略 运维行为测试

> **维度**：系统=NATS | 域=SYN（consumer ack 策略）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream consumer 分别用 explicit/ackAll/none

## When

- 处理一批消息

## Then

- explicit：仅 acked 消息从 deliver set 移除
- ackAll：批量中最大 ack 序列前消息全部确认
- none：broker 自动ack，无重投保证

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-NATS-ACKPOLICY-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
