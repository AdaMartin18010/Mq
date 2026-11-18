# TC-ERR-NATS-TIMEOUT-01：NATS 客户端超时族 边界测试

> **维度**：系统=NATS | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS timeout errors — [nats.go pkg](https://pkg.go.dev/github.com/nats-io/nats.go) / [NATS System Errors](https://docs.nats.io/reference/system/errors)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- Request-Reply 或 JetStream ack 等待超时时客户端收到 `nats: timeout` / `ErrTimeout`
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/timeout/TC-ERR-NATS-TIMEOUT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
