# TC-ERR-ROCKETMQ-UNKWON_TOPIC-01：ROCKETMQ 未知 topic/queue/stream 边界测试

> **维度**：系统=ROCKETMQ | 错误类=UNKWON_TOPIC | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RocketMQ topic not exist code 17 — [GitHub rocketmq-mqtt #165](https://github.com/apache/rocketmq-mqtt/issues/165) / [Stack Overflow](https://stackoverflow.com/questions/43154365/rocketmqmqbrokerexception-code-2-desc-timeout-clean-queue)
> **环境**：E2；**状态**：pending

## Given

- 目标 topic/queue/stream 未创建或已被删除

## When

- 客户端向该不存在的资源执行 publish/consume/declare/create group

## Then

- 向未创建 topic 发送返回 `MQBrokerException: CODE: 17 DESC: topic[...] not exist, apply first please!`
- 客户端在超时/重试窗口内尝试恢复，持续失败则快速失败
- broker 日志或 admin 接口显示资源不存在/404/未知 topic 错误

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-ROCKETMQ-UNKWON_TOPIC-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
