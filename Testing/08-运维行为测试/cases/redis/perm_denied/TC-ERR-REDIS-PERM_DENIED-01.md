# TC-ERR-REDIS-PERM_DENIED-01：REDIS ACL 不足 边界测试

> **维度**：系统=REDIS | 错误类=PERM_DENIED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Redis ACL NOPERM — [Redis ACL](https://redis.io/docs/latest/manual/acl/) / [Redis AUTH](https://redis.io/docs/latest/commands/auth/)
> **环境**：E2；**状态**：pending

## Given

- 使用低权限 principal 执行越权生产/消费/管理操作

## When

- 执行被 ACL 禁止的操作

## Then

- ACL 禁止某命令/键时返回 `NOPERM this user has no permissions to run the ...`
- 客户端收到 ACL 拒绝后停止非法操作并告警（不重试）
- authorizer/ACL 审计日志记录 deny 事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-REDIS-PERM_DENIED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
