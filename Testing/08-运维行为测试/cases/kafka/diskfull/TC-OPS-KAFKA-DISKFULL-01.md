# TC-OPS-KAFKA-DISKFULL-01：KAFKA 磁盘满 运维行为测试

> **维度**：系统=KAFKA | 行为=DISKFULL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68 故障行为
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 单 broker log.dirs 注入填充至阈值

## When

- 继续生产

## Then

- 日志出现 not accepting new data（03-68）
- 清理后自动恢复写（无重启）
- 已落段校验和完整

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-DISKFULL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68 故障行为；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
