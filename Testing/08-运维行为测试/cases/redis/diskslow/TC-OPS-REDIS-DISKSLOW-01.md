# TC-OPS-REDIS-DISKSLOW-01：REDIS 磁盘慢 运维行为测试

> **维度**：系统=REDIS | 行为=DISKSLOW（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- AOF everysec 慢盘

## When

- 持久化

## Then

- fsync 延迟指标

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-REDIS-DISKSLOW-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
