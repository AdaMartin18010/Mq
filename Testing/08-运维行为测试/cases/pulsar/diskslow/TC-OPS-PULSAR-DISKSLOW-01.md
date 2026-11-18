# TC-OPS-PULSAR-DISKSLOW-01：PULSAR 磁盘慢 运维行为测试

> **维度**：系统=PULSAR | 行为=DISKSLOW（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- bookie 慢盘

## When

- 读写路径

## Then

- 读降级到其它副本（01-62 读写路径）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/diskslow/TC-OPS-PULSAR-DISKSLOW-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
