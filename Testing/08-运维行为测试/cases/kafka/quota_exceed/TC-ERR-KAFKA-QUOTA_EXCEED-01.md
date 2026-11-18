# TC-ERR-KAFKA-QUOTA_EXCEED-01：KAFKA 配额超限 边界测试

> **维度**：系统=KAFKA | 错误类=QUOTA_EXCEED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka quota throttle / `POLICY_VIOLATION` error code 44 — [Apache Kafka Protocol Guide](https://kafka.apache.org/26/protocol.html) / [Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)
> **环境**：E2；**状态**：pending

## Given

- 将某用户/流/租户压测至配置配额上限

## When

- 持续发送直到触发配额/限速/存储上限

## Then

- QuotaManager 在响应中返回 `throttle_time_ms`；硬限制下返回 `POLICY_VIOLATION`（error code 44）
- 客户端收到配额超限信号后启用退避/降速，不硬失败
- admin/metrics 显示 throttle/reject/配额指标上升

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/quota_exceed/TC-ERR-KAFKA-QUOTA_EXCEED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
