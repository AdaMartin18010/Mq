# TC-PST-KAFKA-FLUSH-MS-01：log.flush.interval.ms 强制刷盘行为

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.6
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- server.properties 设置 log.flush.interval.ms=1000

## When

- 持续生产并周期性 kill -9 broker

## Then

- 每次 fsync 间隔内消息最多丢失 ≤1000ms 窗口
- acks=all 下已提交消息因多副本存在仍不丢（刷盘仅影响单节点）
- 刷盘 scheduler 按 log.flush.scheduler.interval.ms 检查

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/kafka/flush-ms/TC-PST-KAFKA-FLUSH-MS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.6；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
