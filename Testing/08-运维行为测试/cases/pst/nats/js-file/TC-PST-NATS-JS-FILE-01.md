# TC-PST-NATS-JS-FILE-01：JetStream File 存储重启行为

> **维度**：系统=NATS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- Stream 存储类型=file，R=3

## When

- kill -9 nats-server 并重启

## Then

- 流消息与消费序列持久化到磁盘，重启后恢复
- 已 ack 消息不丢
- FileStore 校验和通过

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-NATS-JS-FILE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
