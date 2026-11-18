# TC-ERR-KAFKA-CONN_RESET-01：KAFKA 连接重置/半开连接 边界测试

> **维度**：系统=KAFKA | 错误类=CONN_RESET | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka EOFException on connection reset — [Stack Overflow](https://stackoverflow.com/questions/33432027/kafka-error-in-i-o-java-io-eofexception-null) / [Confluent Connectivity](https://www.confluent.io/blog/kafka-client-cannot-connect-to-broker-on-aws-on-docker-etc/)
> **环境**：E2；**状态**：pending

## Given

- 在连接活动期间注入 TCP RST 或半开连接/强制关闭 broker 端口

## When

- 观察客户端在连接异常关闭后的行为

## Then

- 连接被对端关闭时客户端日志出现 `java.io.EOFException` 或 `NetworkException`，broker 日志记录 `Connection with ... disconnected`
- 客户端自动重连并恢复会话/订阅；重连风暴可控
- 日志记录连接断开与恢复事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/conn_reset/TC-ERR-KAFKA-CONN_RESET-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
