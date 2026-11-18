# TC-PST-PULSAR-E3WQ3AQ2-01：BookKeeper E3/WQ3/AQ2 持久化阶梯

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 E≥WQ≥AQ
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace persistence E=3 WQ=3 AQ=2

## When

- kill -9 1 bookie

## Then

- 写仍成功（AQ=2 满足）
- 读仍可从存活 2 副本完成
- 丢窗=0（已 ack entry 至少 2 副本）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/pulsar/e3wq3aq2/TC-PST-PULSAR-E3WQ3AQ2-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.2 E≥WQ≥AQ；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
