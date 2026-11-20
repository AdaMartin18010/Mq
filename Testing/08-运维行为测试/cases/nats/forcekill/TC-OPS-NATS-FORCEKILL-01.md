# TC-OPS-NATS-FORCEKILL-01：NATS 强杀恢复 运维行为测试

> **维度**：系统=NATS | 行为=FORCEKILL（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill -9+重启

## When

- 内存态

## Then

- Core 消息丢失声明（反向确认 01-67）
- JetStream 持久数据完整

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-NATS-FORCEKILL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
