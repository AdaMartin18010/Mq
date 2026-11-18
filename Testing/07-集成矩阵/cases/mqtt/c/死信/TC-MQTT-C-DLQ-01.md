# TC-MQTT-C-DLQ-01：C 客户端的 MQTT 死信 用例

> **维度**：系统=MQTT | 语言=C | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given
- 实现层（$DLQ 惯例）

## When
- 失败消息

## Then
- 应用层 $DLQ 隔离模式
- 等级依据：TEST-C2 MQTT×死信=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/c/死信/TC-MQTT-C-DLQ-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65 ○
