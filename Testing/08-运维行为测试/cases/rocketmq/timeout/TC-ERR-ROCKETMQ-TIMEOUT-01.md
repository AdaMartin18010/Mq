# TC-ERR-ROCKETMQ-TIMEOUT-01：ROCKETMQ 客户端超时族 边界测试

> **维度**：系统=ROCKETMQ | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RocketMQ sendMsgTimeout default 3000ms — [RocketMQ Client Config](https://rocketmq.apache.org/docs/4.x/parameterConfiguration/01local/) / [jaskey blog](https://jaskey.github.io/blog/2017/06/13/rocketmq-client-config/)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- 同步发送在 `sendMsgTimeout` 默认 3000ms 未收到响应时抛出 `RemotingTimeoutException`
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rocketmq/timeout/TC-ERR-ROCKETMQ-TIMEOUT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
