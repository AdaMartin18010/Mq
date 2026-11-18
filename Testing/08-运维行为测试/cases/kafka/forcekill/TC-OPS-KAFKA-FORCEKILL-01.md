# TC-OPS-KAFKA-FORCEKILL-01：KAFKA 强杀恢复 运维行为测试

> **维度**：系统=KAFKA | 行为=FORCEKILL（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §故障推演
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- kill -9 + 重启

## When
- RTO+日志校验

## Then
- log-dump 校验段完整
- recovery.point 之后无空洞

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/forcekill/TC-OPS-KAFKA-FORCEKILL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61 §故障推演；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
