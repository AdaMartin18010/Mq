# TC-OPS-PULSAR-METARESTORE-01：PULSAR 元数据恢复 运维行为测试

> **维度**：系统=PULSAR | 行为=METARESTORE（restore 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- Oxia 快照恢复

## When

- 元数据

## Then

- namespace 拓扑恢复一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-PULSAR-METARESTORE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
