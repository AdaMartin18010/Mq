# TC-OPS-NATS-RECONNSTORM-01：NATS 重连风暴 运维行为测试

> **维度**：系统=NATS | 行为=RECONNSTORM（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：04-03
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 客户端批量重连

## When

- 曲线

## Then

- server 无雪崩

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-NATS-RECONNSTORM-01   # 计划打印（dry-run RC=0）
```

## 关联

- 04-03；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
