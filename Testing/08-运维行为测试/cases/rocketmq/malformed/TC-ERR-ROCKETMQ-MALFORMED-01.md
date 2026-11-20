# TC-ERR-ROCKETMQ-MALFORMED-01：ROCKETMQ 畸形消息 边界测试

> **维度**：系统=ROCKETMQ | 错误类=MALFORMED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RocketMQ malformed/command decode — [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/) / [GitHub #3750](https://github.com/apache/rocketmq/issues/3750)
> **环境**：E2；**状态**：pending

## Given

- 构造坏 JSON、超 frame、非法 UTF-8 或 CRC 错误的消息/帧

## When

- 发送/消费该畸形消息或帧

## Then

- 消息体/RemotingCommand 解码失败返回 `CODE: 1` / `MQClientException` / `RemotingCommandException`
- 客户端/ broker 拒绝该条消息并继续处理后续消息（不阻塞）
- 日志中出现 malformed/corrupt/schema/非法帧错误码

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-ROCKETMQ-MALFORMED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
