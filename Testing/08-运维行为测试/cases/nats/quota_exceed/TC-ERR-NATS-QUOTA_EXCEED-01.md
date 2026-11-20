# TC-ERR-NATS-QUOTA_EXCEED-01：NATS 配额超限 边界测试

> **维度**：系统=NATS | 错误类=QUOTA_EXCEED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS JetStream resource limits — [NATS JetStream Errors](https://docs.nats.io/reference/2.11/jetstream/errors) / [GitHub #2599](https://github.com/nats-io/nats-server/issues/2599)
> **环境**：E2；**状态**：pending

## Given

- 将某用户/流/租户压测至配置配额上限

## When

- 持续发送直到触发配额/限速/存储上限

## Then

- JetStream 流/账户达到 `maxBytes/maxMsgs/maxConsumers` 限制返回 `insufficient storage resources available`（10047）/ limit exceeded
- 客户端收到配额超限信号后启用退避/降速，不硬失败
- admin/metrics 显示 throttle/reject/配额指标上升

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-NATS-QUOTA_EXCEED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
