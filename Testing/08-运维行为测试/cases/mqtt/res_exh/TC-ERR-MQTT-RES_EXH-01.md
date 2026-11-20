# TC-ERR-MQTT-RES_EXH-01：MQTT 资源耗尽 边界测试

> **维度**：系统=MQTT | 错误类=RES_EXH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 server unavailable/busy 0x88/0x89 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 将 broker 节点的 FD/内存/磁盘压至上限

## When

- 继续请求并观察 broker 降级行为

## Then

- broker 资源耗尽时返回 `0x88 Server unavailable` / `0x89 Server busy` 或强制断开连接
- broker 进入只读/拒绝新连接；清理资源后自动恢复
- metrics 显示 FD/内存/磁盘耗尽报警

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-MQTT-RES_EXH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
