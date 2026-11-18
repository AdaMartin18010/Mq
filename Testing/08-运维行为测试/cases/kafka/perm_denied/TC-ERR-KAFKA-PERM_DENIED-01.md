# TC-ERR-KAFKA-PERM_DENIED-01：KAFKA ACL 不足 边界测试

> **维度**：系统=KAFKA | 错误类=PERM_DENIED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Kafka authorization error codes 29/30/31 — [IBM Troubleshooting](https://www.ibm.com/docs/en/kafka-zos/1.1.0?topic=troubleshooting) / [Apache Kafka Authorization](https://kafka.apache.org/22/security/authorization-and-acls/)
> **环境**：E2；**状态**：pending

## Given

- 使用低权限 principal 执行越权生产/消费/管理操作

## When

- 执行被 ACL 禁止的操作

## Then

- ACL 不足返回 `TopicAuthorizationException`（error code 29）/ `GROUP_AUTHORIZATION_FAILED`（30）/ `CLUSTER_AUTHORIZATION_FAILED`（31）
- 客户端收到 ACL 拒绝后停止非法操作并告警（不重试）
- authorizer/ACL 审计日志记录 deny 事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/perm_denied/TC-ERR-KAFKA-PERM_DENIED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
