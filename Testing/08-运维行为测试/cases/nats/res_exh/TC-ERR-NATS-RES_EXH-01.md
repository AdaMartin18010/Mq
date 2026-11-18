# TC-ERR-NATS-RES_EXH-01：NATS 资源耗尽 边界测试

> **维度**：系统=NATS | 错误类=RES_EXH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS JetStream resource exhaustion — [NATS JetStream Errors](https://docs.nats.io/reference/2.11/jetstream/errors) / [GitHub #2599](https://github.com/nats-io/nats-server/issues/2599)
> **环境**：E2；**状态**：pending

## Given

- 将 broker 节点的 FD/内存/磁盘压至上限

## When

- 继续请求并观察 broker 降级行为

## Then

- JetStream 存储目录满或 FD 耗尽返回 `insufficient storage resources available`（10047）/ `Too many open files`
- broker 进入只读/拒绝新连接；清理资源后自动恢复
- metrics 显示 FD/内存/磁盘耗尽报警

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/res_exh/TC-ERR-NATS-RES_EXH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
