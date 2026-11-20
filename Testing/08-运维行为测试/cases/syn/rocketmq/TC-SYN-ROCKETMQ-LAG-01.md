# TC-SYN-ROCKETMQ-LAG-01：ROCKETMQ 复制滞后可观测 运维行为测试

> **维度**：系统=ROCKETMQ | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 主从同步复制

## When

- slave 落后 master

## Then

- slave commit offset 与 master commitlog offset diff 可采集
- broker slave fall behind 指标告警
- 告警阈值：offset diff > 10000 或同步复制 RT > 1s

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-ROCKETMQ-LAG-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
