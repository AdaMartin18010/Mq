# TC-OPS-KAFKA-BROKERKILL-01：KAFKA 进程强杀 运维行为测试

> **维度**：系统=KAFKA | 行为=BROKERKILL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67 故障模式
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill -9 leader broker

## When

- RTO 计时

## Then

- ISR 重选≤30s【估算】
- 已 ack 消息不丢
- metadata 无悬挂分区

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/brokerkill/TC-OPS-KAFKA-BROKERKILL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67 故障模式；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
