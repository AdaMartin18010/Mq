# TC-OPS-KAFKA-HOTRELOAD-01：KAFKA 配置热更新 运维行为测试

> **维度**：系统=KAFKA | 行为=HOTRELOAD（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67 配置面
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 动态配置子集（log.retention.ms 等）

## When

- kafka-configs --alter

## Then

- 生效不重启；静态配置拒绝动态修改并提示

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-HOTRELOAD-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-67 配置面；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
