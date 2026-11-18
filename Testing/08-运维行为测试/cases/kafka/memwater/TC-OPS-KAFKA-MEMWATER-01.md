# TC-OPS-KAFKA-MEMWATER-01：KAFKA 内存水位 运维行为测试

> **维度**：系统=KAFKA | 行为=MEMWATER（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68 资源
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 堆填充压测

## When

- broker 内存曲线

## Then

- GC 日志特征符合 03-68 资源模型
- 无 OOM（ExitOnOutOfMemoryError 前兆可观测）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/memwater/TC-OPS-KAFKA-MEMWATER-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68 资源；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
