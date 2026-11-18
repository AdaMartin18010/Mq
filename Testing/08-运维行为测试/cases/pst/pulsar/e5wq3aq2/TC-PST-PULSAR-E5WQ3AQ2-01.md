# TC-PST-PULSAR-E5WQ3AQ2-01：BookKeeper E5/WQ3/AQ2 持久化阶梯

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace persistence E=5 WQ=3 AQ=2

## When

- kill -9 2 bookies（落在不同故障域）

## Then

- 写仍成功（AQ=2 满足，且 WQ 副本落在其余 bookie）
- 读仍可用
- 容错边界优于 E3 配置

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/pulsar/e5wq3aq2/TC-PST-PULSAR-E5WQ3AQ2-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
