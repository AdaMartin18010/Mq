# TC-PULSAR-GO-TTL-01：GO 客户端的 PULSAR TTL过期 用例

> **维度**：系统=PULSAR | 语言=GO | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- topic ttl

## When
- 过期

## Then
- 过期消息不可见
- 等级依据：TEST-C2 PULSAR×TTL过期=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/go/TTL过期/TC-PULSAR-GO-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62 ●
