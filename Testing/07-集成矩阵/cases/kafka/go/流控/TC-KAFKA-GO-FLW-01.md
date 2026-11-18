# TC-KAFKA-GO-FLW-01：GO 客户端的 KAFKA 流控 用例

> **维度**：系统=KAFKA | 语言=GO | 特性=FLW(流控) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 流控格
> **环境**：E2 docker；**状态**：pending

## Given
- fetch.max.bytes/quota

## When
- 高并发拉取

## Then
- 配额限流可观测
- 等级依据：TEST-C2 KAFKA×流控=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/go/流控/TC-KAFKA-GO-FLW-01.sh   # 计划打印（挂账）
```

## 关联
- 01-71 fetch 全字段
