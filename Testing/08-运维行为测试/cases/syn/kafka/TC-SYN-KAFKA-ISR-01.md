# TC-SYN-KAFKA-ISR-01：KAFKA ISR 收缩与扩展 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（ISR 收缩与扩展）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR 收缩 / §1.61.7 副本落后恢复
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- RF=3 中一个 follower 变慢

## When

- 落后超出 replica.lag.time.max.ms

## Then

- ISR 收缩，IsrShrinksPerSec 触发
- acks=all 写入失败直到 ISR 恢复≥min.insync.replicas
- follower 追赶后 ISR 扩展，IsrExpandsPerSec 触发

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-KAFKA-ISR-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2 ISR 收缩 / §1.61.7 副本落后恢复；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
