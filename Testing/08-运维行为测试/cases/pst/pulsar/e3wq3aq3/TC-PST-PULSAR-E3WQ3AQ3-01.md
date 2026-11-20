# TC-PST-PULSAR-E3WQ3AQ3-01：BookKeeper E3/WQ3/AQ3 强一致阶梯

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace persistence E=3 WQ=3 AQ=3

## When

- kill -9 1 bookie

## Then

- 写需全部 3 副本 ack，1 台故障即不可写
- 读仍可用
- 丢窗=0，可用性换一致性

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-PULSAR-E3WQ3AQ3-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
