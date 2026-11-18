# TC-PST-KAFKA-FLUSH-MSGS-01：log.flush.interval.messages 强制刷盘行为

> **维度**：系统=KAFKA | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.6
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- server.properties 设置 log.flush.interval.messages=10000

## When

- 持续生产至 10000 条时 kill -9 leader

## Then

- 未达刷盘阈值的消息依赖 OS 页缓存，可能丢失
- 达到阈值后 fsync 落盘，kill -9 后可恢复
- 丢窗上界 ≤ log.flush.interval.messages 条（OS 未刷盘部分按估算）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/kafka/flush-msgs/TC-PST-KAFKA-FLUSH-MSGS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.6；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
