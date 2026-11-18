# TC-MQTT-RS-FLT-01：RS 客户端的 MQTT 消息过滤 用例

> **维度**：系统=MQTT | 语言=RS | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given
- topic 通配符订阅

## When
- 模式过滤

## Then
- 通配匹配正确【定理】
- 等级依据：TEST-C2 MQTT×消息过滤=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/rs/消息过滤/TC-MQTT-RS-FLT-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64
