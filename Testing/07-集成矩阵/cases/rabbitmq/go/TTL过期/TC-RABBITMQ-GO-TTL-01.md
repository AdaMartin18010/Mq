# TC-RABBITMQ-GO-TTL-01：GO 客户端的 RABBITMQ TTL过期 用例

> **维度**：系统=RABBITMQ | 语言=GO | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- per-message TTL+队列 TTL

## When
- 过期消息

## Then
- 过期即清理可观测
- 等级依据：TEST-C2 RABBITMQ×TTL过期=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/go/TTL过期/TC-RABBITMQ-GO-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 ●
