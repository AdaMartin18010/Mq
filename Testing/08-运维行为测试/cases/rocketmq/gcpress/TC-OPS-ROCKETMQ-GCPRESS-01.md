# TC-OPS-ROCKETMQ-GCPRESS-01：ROCKETMQ GC 压力 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=GCPRESS（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JVM 填充

## When

- 停顿

## Then

- 特征

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-ROCKETMQ-GCPRESS-01   # 计划打印（dry-run RC=0）
```

## 关联

- 【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
