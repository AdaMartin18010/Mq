# TC-SYN-RABBITMQ-FED-01：RABBITMQ federation 断连恢复 运维行为测试

> **维度**：系统=RABBITMQ | 域=SYN（federation 断连恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RabbitMQ 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- federation upstream 绑定队列

## When

- upstream 链路断开再恢复

## Then

- 断连期间消息在 upstream 队列堆积（TTL/长度策略）
- 恢复后 buffered 消息回放至 downstream
- fanout 冲突（同名 binding）可观测

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/rabbitmq/TC-SYN-RABBITMQ-FED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 RabbitMQ 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
