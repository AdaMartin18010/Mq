# TC-ERR-PULSAR-VER_MISMATCH-01：PULSAR 协议/客户端版本不匹配 边界测试

> **维度**：系统=PULSAR | 错误类=VER_MISMATCH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Pulsar client/server compatibility — [Alibaba Cloud](https://developer.aliyun.com/ask/575669) / [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/)
> **环境**：E2；**状态**：pending

## Given

- 使用旧版客户端或错误协议版本连接当前 broker

## When

- 进行协议握手或 ApiVersions 协商

## Then

- 客户端与服务端版本或协议不兼容导致 handshake / `IncompatibleSchemaException` 失败
- 客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）
- broker 日志记录不支持的协议/客户端版本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pulsar/ver_mismatch/TC-ERR-PULSAR-VER_MISMATCH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
