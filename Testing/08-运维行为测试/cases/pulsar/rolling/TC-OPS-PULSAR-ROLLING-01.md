# TC-OPS-PULSAR-ROLLING-01：PULSAR 滚动重启 运维行为测试

> **维度**：系统=PULSAR | 行为=ROLLING（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 逐 bookie 滚动

## When

- 写入连续

## Then

- 无写入中断（01-62 运维窗口）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/rolling/TC-OPS-PULSAR-ROLLING-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
