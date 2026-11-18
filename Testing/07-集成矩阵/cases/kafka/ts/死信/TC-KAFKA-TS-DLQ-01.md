# TC-KAFKA-TS-DLQ-01：TS 客户端的 KAFKA 死信 用例

> **维度**：系统=KAFKA | 语言=TS | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given
- Kafka 4.4（fixtures 已锁）；share group + share.dlq.topic

## When
- 毒消息至 delivery 上限

## Then
- 入 DLQ 且主 share 不停（KIP-1191）
- 4.4 前无原生=配置等级
- 等级依据：TEST-C2 KAFKA×死信=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/ts/死信/TC-KAFKA-TS-DLQ-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65/TC-KAFKA-GO-DLQ-01
