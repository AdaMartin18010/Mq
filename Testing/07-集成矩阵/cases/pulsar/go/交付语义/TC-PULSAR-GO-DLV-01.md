# TC-PULSAR-GO-DLV-01：GO 客户端的 交付语义 断言

> **维度**：系统=PULSAR | 语言=GO | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- pulsar-broker-config.conf；go 客户端订阅 Shared

## When

- 生产+broker 滚动重启一台

## Then

- 已持久化消息不丢（持久 topic）
- Shared 订阅故障转移完成

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/pulsar/go/交付语义/TC-PULSAR-GO-DLV-01.sh   # 计划打印
```

## 关联

- 01-62 读写路径；语义矩阵 Pulsar=●
