# TC-KAFKA-C-DLV-01：C 客户端的 KAFKA 交付语义 用例

> **维度**：系统=KAFKA | 语言=C | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given
- 3 broker KRaft，min.insync.replicas=2；acks=all+幂等生产者

## When
- 生产 500 条后 kill 确认副本

## Then
- 已确认消息不丢（ASE-001）
- 重复计数≤1
- 等级依据：TEST-C2 KAFKA×交付语义=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/c/交付语义/TC-KAFKA-C-DLV-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61 ISR 语义
