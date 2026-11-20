# TC-OPS-RABBITMQ-DISKSLOW-01：RABBITMQ 磁盘慢 运维行为测试

> **维度**：系统=RABBITMQ | 行为=DISKSLOW（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 延迟代理数据目录

## When

- 持久化队列

## Then

- 持久化吞吐下降
- 内存队列受影小（对照）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-RABBITMQ-DISKSLOW-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
