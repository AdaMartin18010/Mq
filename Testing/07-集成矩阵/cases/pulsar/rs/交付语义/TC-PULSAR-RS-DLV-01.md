# TC-PULSAR-RS-DLV-01：RS 客户端的 PULSAR 交付语义 用例

> **维度**：系统=PULSAR | 语言=RS | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given
- 持久 topic+副本

## When
- 确认后宕机

## Then
- 已确认不丢
- 等级依据：TEST-C2 PULSAR×交付语义=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/rs/交付语义/TC-PULSAR-RS-DLV-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62
