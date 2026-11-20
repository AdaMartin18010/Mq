# TC-OPS-KAFKA-METARESTORE-01：KAFKA 元数据恢复 运维行为测试

> **维度**：系统=KAFKA | 行为=METARESTORE（restore 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 删除 controller 快照目录

## When

- 重启

## Then

- 从最近快照+日志恢复
- epoch 单调

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-METARESTORE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
