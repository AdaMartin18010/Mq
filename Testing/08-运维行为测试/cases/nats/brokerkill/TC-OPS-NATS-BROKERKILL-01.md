# TC-OPS-NATS-BROKERKILL-01：NATS 进程强杀 运维行为测试

> **维度**：系统=NATS | 行为=BROKERKILL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill -9

## When

- RTO

## Then

- Core 无状态恢复快
- JetStream 流恢复（RTO 计时）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/brokerkill/TC-OPS-NATS-BROKERKILL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
