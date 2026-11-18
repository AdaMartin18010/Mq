# TC-KAFKA-GO-PST-01：GO 客户端的 KAFKA 持久化 用例

> **维度**：系统=KAFKA | 语言=GO | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given
- segment+副本持久化

## When
- broker 重启

## Then
- 已提交段完整
- 页缓存依赖声明
- 等级依据：TEST-C2 KAFKA×持久化=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/go/持久化/TC-KAFKA-GO-PST-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61
