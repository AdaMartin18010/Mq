# TC-MQTT-RS-TTL-01：RS 客户端的 MQTT TTL过期 用例

> **维度**：系统=MQTT | 语言=RS | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- 消息过期间隔（v5）

## When
- 离线过期

## Then
- 过期不投递（ASE-012）
- 等级依据：TEST-C2 MQTT×TTL过期=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/rs/TTL过期/TC-MQTT-RS-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64 【定理】
