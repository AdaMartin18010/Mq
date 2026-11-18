# TC-OPS-KAFKA-CLIENTFLOOD-01：KAFKA 连接风暴 运维行为测试

> **维度**：系统=KAFKA | 行为=CLIENTFLOOD（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 1000 并发 producer

## When

- 连接指标

## Then

- accept 队列行为符合内核参数
- broker 无雪崩

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/clientflood/TC-OPS-KAFKA-CLIENTFLOOD-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
