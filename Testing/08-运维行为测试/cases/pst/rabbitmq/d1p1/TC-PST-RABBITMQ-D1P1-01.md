# TC-PST-RABBITMQ-D1P1-01：durable=true/persistent=true 重启矩阵

> **维度**：系统=RABBITMQ | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 声明 durable 队列，发布 persistent=true 消息

## When

- restart broker

## Then

- 队列与消息均恢复
- 已 confirm 消息不丢
- 丢窗≤未 confirm 且在内存缓冲中的消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/rabbitmq/d1p1/TC-PST-RABBITMQ-D1P1-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
