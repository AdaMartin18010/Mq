# TC-ERR-PULSAR-CONN_RESET-01：PULSAR 连接重置/半开连接 边界测试

> **维度**：系统=PULSAR | 错误类=CONN_RESET | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Pulsar connection reset — [GitHub #10231](https://github.com/apache/pulsar/issues/10231) / [pulsar-client-go #1312](https://github.com/apache/pulsar-client-go/issues/1312)
> **环境**：E2；**状态**：pending

## Given

- 在连接活动期间注入 TCP RST 或半开连接/强制关闭 broker 端口

## When

- 观察客户端在连接异常关闭后的行为

## Then

- broker 重启或网络闪断导致 Netty `IOException` / `Connection reset by peer`，客户端自动重连
- 客户端自动重连并恢复会话/订阅；重连风暴可控
- 日志记录连接断开与恢复事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-PULSAR-CONN_RESET-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
