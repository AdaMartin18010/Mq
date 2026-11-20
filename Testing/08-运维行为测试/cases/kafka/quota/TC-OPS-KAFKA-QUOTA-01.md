# TC-OPS-KAFKA-QUOTA-01：KAFKA 配额生效 运维行为测试

> **维度**：系统=KAFKA | 行为=QUOTA（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 生产/消费超 produce/fetch 配额

## When

- 压测

## Then

- throttle 时间可观测（QuotaManager 指标）
- 超限报错而非静默

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-QUOTA-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
