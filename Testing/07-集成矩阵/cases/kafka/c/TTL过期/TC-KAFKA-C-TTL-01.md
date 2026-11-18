# TC-KAFKA-C-TTL-01：C 客户端的 KAFKA TTL过期 用例

> **维度**：系统=KAFKA | 语言=C | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- topic retention（无 per-message TTL）

## When
- 消息超保留期

## Then
- 过期段清理可观测
- 消息级 TTL 需应用层（等级○依据）
- 等级依据：TEST-C2 KAFKA×TTL过期=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/c/TTL过期/TC-KAFKA-C-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-72/TEST-C2
