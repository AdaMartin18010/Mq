# TC-OPS-REDIS-DYNCONFIG-01：REDIS 动态配置域 运维行为测试

> **维度**：系统=REDIS | 行为=DYNCONFIG（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- CONFIG SET vs 配置文件

## When

- 一致性

## Then

- 运行时与持久化对账

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-REDIS-DYNCONFIG-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
