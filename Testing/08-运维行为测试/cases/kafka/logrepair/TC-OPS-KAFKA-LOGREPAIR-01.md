# TC-OPS-KAFKA-LOGREPAIR-01：KAFKA 日志修复 运维行为测试

> **维度**：系统=KAFKA | 行为=LOGREPAIR（restore 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 截断最后段文件 1KB

## When
- 重启

## Then
- 坏段隔离+恢复点之前完整
- log-dump 可审计

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/logrepair/TC-OPS-KAFKA-LOGREPAIR-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
