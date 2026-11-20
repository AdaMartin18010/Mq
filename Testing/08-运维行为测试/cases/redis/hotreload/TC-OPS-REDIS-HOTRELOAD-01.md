# TC-OPS-REDIS-HOTRELOAD-01：REDIS 配置热更新 运维行为测试

> **维度**：系统=REDIS | 行为=HOTRELOAD（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- CONFIG SET 全集

## When

- 生效域

## Then

- 运行时全量（对照 03-67）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-REDIS-HOTRELOAD-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
