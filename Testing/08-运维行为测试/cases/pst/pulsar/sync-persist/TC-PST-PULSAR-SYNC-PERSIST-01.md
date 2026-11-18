# TC-PST-PULSAR-SYNC-PERSIST-01：Pulsar 同步持久化 ACK

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.3
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer send 等待持久化 ACK（默认）

## When

- kill broker 后重连

## Then

- broker 返回 ACK 前 entry 已落 BookKeeper（AQ 确认）
- 已 ack 消息不丢
- broker 无状态，恢复后 topic ownership 重新选举

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/pulsar/sync-persist/TC-PST-PULSAR-SYNC-PERSIST-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.3；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
