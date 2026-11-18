# TC-ERR-KAFKA-VER_MISMATCH-01：KAFKA 协议/客户端版本不匹配 边界测试

> **维度**：系统=KAFKA | 错误类=VER_MISMATCH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka `UNSUPPORTED_VERSION` error code 35 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/UNSUPPORTED_VERSION/) / [Apache Kafka Upgrade](https://kafka.apache.org/32/getting-started/upgrade/)
> **环境**：E2；**状态**：pending

## Given

- 使用旧版客户端或错误协议版本连接当前 broker

## When

- 进行协议握手或 ApiVersions 协商

## Then

- 客户端请求 API version 不被 broker 支持时返回 `UNSUPPORTED_VERSION`（error code 35）
- 客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）
- broker 日志记录不支持的协议/客户端版本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/ver_mismatch/TC-ERR-KAFKA-VER_MISMATCH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
