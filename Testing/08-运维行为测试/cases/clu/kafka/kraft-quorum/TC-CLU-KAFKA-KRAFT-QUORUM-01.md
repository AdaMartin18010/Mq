# TC-CLU-KAFKA-KRAFT-QUORUM-01：Kafka KRaft controller quorum 分区

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.4
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 controller KRaft quorum

## When

- 网络分区隔离 1 controller

## Then

- 多数派继续提供元数据写
- 少数派 controller 停止处理变更
- broker 元数据缓存仍可读，直至 reconnect 到 active quorum

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/kafka/kraft-quorum/TC-CLU-KAFKA-KRAFT-QUORUM-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.4；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
