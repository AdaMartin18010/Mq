# TC-ERR-ROCKETMQ-PERM_DENIED-01：ROCKETMQ ACL 不足 边界测试

> **维度**：系统=ROCKETMQ | 错误类=PERM_DENIED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：RocketMQ ACL permission denied — [RocketMQ Access Control 4.x](https://rocketmq.apache.org/docs/4.x/bestPractice/04access/) / [Tencent Cloud](https://www.tencentcloud.com/zh/document/product/1113/54437)
> **环境**：E2；**状态**：pending

## Given

- 使用低权限 principal 执行越权生产/消费/管理操作

## When

- 执行被 ACL 禁止的操作

## Then

- ACL 权限不足返回 `NO_PERMISSION` / `AclException: [PRODUCE/SUBSCRIBE] ... no permission`
- 客户端收到 ACL 拒绝后停止非法操作并告警（不重试）
- authorizer/ACL 审计日志记录 deny 事件

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rocketmq/perm_denied/TC-ERR-ROCKETMQ-PERM_DENIED-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
