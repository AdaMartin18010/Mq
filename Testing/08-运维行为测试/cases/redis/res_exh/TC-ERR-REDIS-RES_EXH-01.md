# TC-ERR-REDIS-RES_EXH-01：REDIS 资源耗尽 边界测试

> **维度**：系统=REDIS | 错误类=RES_EXH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Redis resource exhaustion — [Redis Clients](https://https://redis.io/docs/latest/develop/reference/clients/) / [OneUptime maxclients](https://oneuptime.com/blog/post/2026-01-25-redis-max-clients-reached-fix/view)
> **环境**：E2；**状态**：pending

## Given

- 将 broker 节点的 FD/内存/磁盘压至上限

## When

- 继续请求并观察 broker 降级行为

## Then

- 内存耗尽 `OOM command not allowed` 或连接数达到 `maxclients` 返回 `ERR max number of clients reached`
- broker 进入只读/拒绝新连接；清理资源后自动恢复
- metrics 显示 FD/内存/磁盘耗尽报警

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-REDIS-RES_EXH-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
