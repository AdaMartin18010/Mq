# TC-SYN-PULSAR-SYNC-01：PULSAR sync vs async 持久化 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（sync vs async 持久化）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 E/WQ/AQ / 01-63 §1.63.7 Pulsar 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer send 等待持久化 ack（默认持久化）

## When

- bookie AQ 返回前

## Then

- broker 等待 AQ 个 bookie 确认后才 ack producer
- 可配置 E/WQ/AQ 调整一致性与延迟
- 行为符合 01-62 ensemble/quorum 语义

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/pulsar/TC-SYN-PULSAR-SYNC-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.2 E/WQ/AQ / 01-63 §1.63.7 Pulsar 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
