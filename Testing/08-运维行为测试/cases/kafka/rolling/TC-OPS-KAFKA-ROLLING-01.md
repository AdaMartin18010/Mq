# TC-OPS-KAFKA-ROLLING-01：KAFKA 滚动重启 运维行为测试

> **维度**：系统=KAFKA | 行为=ROLLING（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67 升级路径
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 逐 broker 滚动重启（单节点退化为重启窗口）

## When

- 消费连续性

## Then

- 窗口内消费者重平衡完成
- 无消息丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/rolling/TC-OPS-KAFKA-ROLLING-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67 升级路径；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
