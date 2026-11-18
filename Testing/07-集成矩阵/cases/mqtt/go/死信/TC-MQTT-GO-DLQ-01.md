# TC-MQTT-GO-DLQ-01：GO 客户端的 死信 断言

> **维度**：系统=MQTT | 语言=GO | 特性=DLQ | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- 应用层模式：主题桥接至处理队列+失败转 $dlq 主题

## When

- 处理失败消息

## Then

- $dlq 主题隔离
- 遗嘱消息联动验证

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/mqtt/go/死信/TC-MQTT-GO-DLQ-01.sh   # 计划打印
```

## 关联

- 01-65 MQTT 实现层路径；反向用例
