# TC-PST-NATS-JS-MEMORY-01：JetStream Memory 存储重启行为

> **维度**：系统=NATS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- Stream 存储类型=memory，R=3

## When

- kill -9 nats-server 并重启

## Then

- memory 流消息全部丢失（无持久化）
- 消费者序列重置
- 丢窗=全部未消费消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-NATS-JS-MEMORY-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
