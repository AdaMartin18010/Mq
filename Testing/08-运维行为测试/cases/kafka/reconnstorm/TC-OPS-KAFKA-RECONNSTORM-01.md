# TC-OPS-KAFKA-RECONNSTORM-01：KAFKA 重连风暴 运维行为测试

> **维度**：系统=KAFKA | 行为=RECONNSTORM（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：04-03/01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- kill 全部消费者立即恢复

## When
- 重连曲线

## Then
- 退避行为符合客户端默认
- 无重试放大失控（04-03 α 系数观测）

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/reconnstorm/TC-OPS-KAFKA-RECONNSTORM-01.sh   # 计划打印（挂账）
```

## 关联
- 04-03/01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
