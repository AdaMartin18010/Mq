# TC-ERR-NATS-VER_MISMATCH-01：NATS 协议/客户端版本不匹配 边界测试

> **维度**：系统=NATS | 错误类=VER_MISMATCH | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：NATS client/server version negotiation — [nats.go pkg](https://pkg.go.dev/github.com/nats-io/nats.go) / [NATS System Errors](https://docs.nats.io/reference/system/errors)
> **环境**：E2；**状态**：pending

## Given

- 使用旧版客户端或错误协议版本连接当前 broker

## When

- 进行协议握手或 ApiVersions 协商

## Then

- 旧客户端无法识别 server INFO 中的 `tls_required` 或新协议特性时返回 `SecureConnRequired` / 握手失败
- 客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）
- broker 日志记录不支持的协议/客户端版本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/ver_mismatch/TC-ERR-NATS-VER_MISMATCH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
