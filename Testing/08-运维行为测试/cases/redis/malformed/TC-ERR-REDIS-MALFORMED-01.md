# TC-ERR-REDIS-MALFORMED-01：REDIS 畸形消息 边界测试

> **维度**：系统=REDIS | 错误类=MALFORMED | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：Redis RESP protocol errors — [Redis Protocol](https://redis.io/docs/latest/develop/reference/protocol-spec/) / [Redis Commands](https://redis.io/docs/latest/commands/)
> **环境**：E2；**状态**：pending

## Given

- 构造坏 JSON、超 frame、非法 UTF-8 或 CRC 错误的消息/帧

## When

- 发送/消费该畸形消息或帧

## Then

- 非法 RESP 帧/非法 UTF-8/命令参数错误返回 `ERR Protocol error` / `ERR wrong number of arguments`
- 客户端/ broker 拒绝该条消息并继续处理后续消息（不阻塞）
- 日志中出现 malformed/corrupt/schema/非法帧错误码

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ERR-REDIS-MALFORMED-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
