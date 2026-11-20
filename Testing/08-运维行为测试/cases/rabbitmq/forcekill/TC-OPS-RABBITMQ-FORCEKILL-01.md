# TC-OPS-RABBITMQ-FORCEKILL-01：RABBITMQ 强杀恢复 运维行为测试

> **维度**：系统=RABBITMQ | 行为=FORCEKILL（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill -9+重启

## When

- 消息校验

## Then

- 持久化消息存活
- 事务回滚

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-RABBITMQ-FORCEKILL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
