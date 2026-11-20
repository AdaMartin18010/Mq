# TC-PST-RABBITMQ-D0P0-01：durable=false/persistent=false 重启矩阵

> **维度**：系统=RABBITMQ | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65 RabbitMQ 持久化语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 声明非持久队列，发布非持久消息

## When

- restart broker

## Then

- 队列不存在（已丢失）
- 消息不存在
- 丢窗=全部未消费消息（无持久化承诺）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-RABBITMQ-D0P0-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-65 RabbitMQ 持久化语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
