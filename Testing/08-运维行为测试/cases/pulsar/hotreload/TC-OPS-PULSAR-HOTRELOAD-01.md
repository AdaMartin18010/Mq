# TC-OPS-PULSAR-HOTRELOAD-01：PULSAR 配置热更新 运维行为测试

> **维度**：系统=PULSAR | 行为=HOTRELOAD（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 动态配置 alter

## When

- 生效域

## Then

- 负载均衡器动态生效

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-PULSAR-HOTRELOAD-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
