# TC-OPS-KAFKA-GCPRESS-01：KAFKA GC 压力 运维行为测试

> **维度**：系统=KAFKA | 行为=GCPRESS（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 老年代填充至 80%

## When

- 生产持续

## Then

- 停顿频率上升可观测
- ZGC/G1 特征符合配置

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-GCPRESS-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
