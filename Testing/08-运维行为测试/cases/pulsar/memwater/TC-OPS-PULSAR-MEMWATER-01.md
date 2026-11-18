# TC-OPS-PULSAR-MEMWATER-01：PULSAR 内存水位 运维行为测试

> **维度**：系统=PULSAR | 行为=MEMWATER（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 堆压测

## When
- GC

## Then
- 停顿特征

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/pulsar/memwater/TC-OPS-PULSAR-MEMWATER-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
