# TC-ERR-NATS-UNKWON_TOPIC-01：NATS 未知 topic/queue/stream 边界测试

> **维度**：系统=NATS | 错误类=UNKWON_TOPIC | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS JetStream `stream not found` 10059 — [NATS Docs](https://docs.nats.io/reference/2.11/jetstream/errors) / [NATS ADR-1](https://github.com/nats-io/nats-architecture-and-design/blob/main/adr/ADR-1.md)
> **环境**：E2；**状态**：pending

## Given

- 目标 topic/queue/stream 未创建或已被删除

## When

- 客户端向该不存在的资源执行 publish/consume/declare/create group

## Then

- JetStream 访问不存在的 stream 返回 `JSStreamNotFoundErr`（err_code 10059，HTTP 404）；Core NATS 无订阅者时请求端收到 `no responders`
- 客户端在超时/重试窗口内尝试恢复，持续失败则快速失败
- broker 日志或 admin 接口显示资源不存在/404/未知 topic 错误

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/unkwon_topic/TC-ERR-NATS-UNKWON_TOPIC-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
