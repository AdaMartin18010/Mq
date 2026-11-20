# TC-ERR-MQTT-PERM_DENIED-01：MQTT ACL 不足 边界测试

> **维度**：系统=MQTT | 错误类=PERM_DENIED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：MQTT v5 not authorized 0x87 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)
> **环境**：E2；**状态**：pending

## Given

- 使用低权限 principal 执行越权生产/消费/管理操作

## When

- 执行被 ACL 禁止的操作

## Then

- ACL 拒绝发布/订阅时返回 `0x87 Not authorized`（CONNACK/PUBACK/SUBACK/DISCONNECT）
- 客户端收到 ACL 拒绝后停止非法操作并告警（不重试）
- authorizer/ACL 审计日志记录 deny 事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-MQTT-PERM_DENIED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
