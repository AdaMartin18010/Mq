# TC-OPS-PULSAR-LOGREPAIR-01：PULSAR 日志修复 运维行为测试

> **维度**：系统=PULSAR | 行为=LOGREPAIR（restore 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- bookie entry 校验和损坏

## When

- 读取

## Then

- 坏 entry 隔离+副本读取

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/logrepair/TC-OPS-PULSAR-LOGREPAIR-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
