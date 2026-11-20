# TC-OPS-PULSAR-NETPART-01：PULSAR 网络分区 运维行为测试

> **维度**：系统=PULSAR | 行为=NETPART（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 隔离 bookie 组

## When

- 读写

## Then

- ensemble 重选
- 恢复后 re-replicate

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-PULSAR-NETPART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
