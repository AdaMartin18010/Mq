# TC-OPS-KAFKA-DISKSLOW-01：KAFKA 磁盘慢 运维行为测试

> **维度**：系统=KAFKA | 行为=DISKSLOW（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.7/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- iostat 注入读延迟 100ms+

## When

- 生产+消费并发

## Then

- p99 上升可观测
- ISR 收缩行为符合 01-61 推演表
- 慢盘副本被踢出后恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-DISKSLOW-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.7/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
