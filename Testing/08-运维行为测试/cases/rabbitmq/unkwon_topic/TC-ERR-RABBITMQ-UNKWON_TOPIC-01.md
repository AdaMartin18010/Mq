# TC-ERR-RABBITMQ-UNKWON_TOPIC-01：RABBITMQ 未知 topic/queue/stream 边界测试

> **维度**：系统=RABBITMQ | 错误类=UNKWON_TOPIC | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RabbitMQ `NOT_FOUND` 404 — [DevOps AI Toolkit](https://devopsaitoolkit.com/blog/rabbitmq-error-not-found-no-queue-exchange/) / [CSDN 实录](https://wenku.csdn.net/answer/65ofe93zj2)
> **环境**：E2；**状态**：pending

## Given

- 目标 topic/queue/stream 未创建或已被删除

## When

- 客户端向该不存在的资源执行 publish/consume/declare/create group

## Then

- 向不存在的 queue/exchange 操作时 broker 返回 `NOT_FOUND`（AMQP reply code 404）并关闭 channel
- 客户端在超时/重试窗口内尝试恢复，持续失败则快速失败
- broker 日志或 admin 接口显示资源不存在/404/未知 topic 错误

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-RABBITMQ-UNKWON_TOPIC-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
