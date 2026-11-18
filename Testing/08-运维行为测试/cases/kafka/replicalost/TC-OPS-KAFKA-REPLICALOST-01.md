# TC-OPS-KAFKA-REPLICALOST-01：KAFKA 副本失联 运维行为测试

> **维度**：系统=KAFKA | 行为=REPLICALOST（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 复制协议
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- pause 一副本 60s

## When

- 观察 ISR

## Then

- ISR 收缩时机符合 replica.lag.time.max.ms
- 恢复后追赶再入 ISR

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/replicalost/TC-OPS-KAFKA-REPLICALOST-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 复制协议；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
