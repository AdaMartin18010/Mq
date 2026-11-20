# TC-OPS-NATS-MSGSIZE-01：NATS 消息大小上限 运维行为测试

> **维度**：系统=NATS | 行为=MSGSIZE（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-72
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 超 max_payload=1MiB（01-72）

## When

- 发布

## Then

- Maximum Payload Exceeded
- 边界通过

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-NATS-MSGSIZE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-72；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
