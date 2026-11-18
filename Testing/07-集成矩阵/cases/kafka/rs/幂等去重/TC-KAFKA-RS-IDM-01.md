# TC-KAFKA-RS-IDM-01：RS 客户端的 KAFKA 幂等去重 用例

> **维度**：系统=KAFKA | 语言=RS | 特性=IDM(幂等去重) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 幂等去重格
> **环境**：E2 docker；**状态**：pending

## Given
- enable.idempotence=true

## When
- broker 故障转移触发重试

## Then
- 单分区日志无重复序列号
- 等级依据：TEST-C2 KAFKA×幂等去重=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/rs/幂等去重/TC-KAFKA-RS-IDM-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 KIP-98
