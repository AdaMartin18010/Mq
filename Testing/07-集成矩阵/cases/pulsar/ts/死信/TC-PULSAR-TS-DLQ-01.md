# TC-PULSAR-TS-DLQ-01：TS 客户端的 PULSAR 死信 用例

> **维度**：系统=PULSAR | 语言=TS | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given
- namespace DLQ policy

## When
- nack 超 maxRedeliverCount

## Then
- 入 DLQ topic（ASE-008）
- 等级依据：TEST-C2 PULSAR×死信=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/ts/死信/TC-PULSAR-TS-DLQ-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65 ●
