# TC-ERR-PULSAR-RES_EXH-01：PULSAR 资源耗尽 边界测试

> **维度**：系统=PULSAR | 错误类=RES_EXH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Pulsar resource exhaustion — [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/) / [Apache Pulsar Message Deduplication](https://pulsar.apache.org/docs/2.4.0/cookbooks-deduplication/)
> **环境**：E2；**状态**：pending

## Given

- 将 broker 节点的 FD/内存/磁盘压至上限

## When

- 继续请求并观察 broker 降级行为

## Then

- Bookie/JVM 内存或磁盘耗尽导致写入失败、broker OOM 或 FD 耗尽
- broker 进入只读/拒绝新连接；清理资源后自动恢复
- metrics 显示 FD/内存/磁盘耗尽报警

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-PULSAR-RES_EXH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
