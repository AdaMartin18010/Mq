# TC-OPS-PULSAR-BROKERKILL-01：PULSAR 进程强杀 运维行为测试

> **维度**：系统=PULSAR | 行为=BROKERKILL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill broker

## When

- RTO

## Then

- topic 重指派
- 无状态 broker 恢复快

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/brokerkill/TC-OPS-PULSAR-BROKERKILL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
