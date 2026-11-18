# TC-OPS-RABBITMQ-RECONNSTORM-01：RABBITMQ 重连风暴 运维行为测试

> **维度**：系统=RABBITMQ | 行为=RECONNSTORM（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：04-03
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 消费者批量重连

## When
- 重连曲线

## Then
- 无重连风暴失控

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rabbitmq/reconnstorm/TC-OPS-RABBITMQ-RECONNSTORM-01.sh   # 计划打印（挂账）
```

## 关联
- 04-03；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
