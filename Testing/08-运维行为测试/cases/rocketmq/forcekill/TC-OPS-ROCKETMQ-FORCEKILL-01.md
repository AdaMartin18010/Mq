# TC-OPS-ROCKETMQ-FORCEKILL-01：ROCKETMQ 强杀恢复 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=FORCEKILL（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- kill -9

## When
- commitlog 校验

## Then
- 恢复后消息完整

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rocketmq/forcekill/TC-OPS-ROCKETMQ-FORCEKILL-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
