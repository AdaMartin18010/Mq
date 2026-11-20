# TC-ERR-REDIS-TIMEOUT-01：REDIS 客户端超时族 边界测试

> **维度**：系统=REDIS | 错误类=TIMEOUT | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Redis client timeout — [Redis Clients](https://redis.io/docs/latest/develop/reference/clients/) / [BLPOP](https://redis.io/docs/latest/commands/blpop/)
> **环境**：E2；**状态**：pending

## Given

- 网络延迟注入或 broker 处理延迟超过客户端超时阈值

## When

- 等待响应/ack/心跳超时

## Then

- 客户端 socket 超时或阻塞命令（如 `BLPOP`）等待超时；空闲连接被 `timeout` 配置关闭
- 客户端在超时后按重试策略重试；超过 max retries 则快速失败
- metrics 中 request-latency/timeout 计数增加

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-REDIS-TIMEOUT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
