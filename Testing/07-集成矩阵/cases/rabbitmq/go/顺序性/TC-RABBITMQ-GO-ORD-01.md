# TC-RABBITMQ-GO-ORD-01：GO 客户端的 RABBITMQ 顺序性 用例

> **维度**：系统=RABBITMQ | 语言=GO | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given
- 单队列 FIFO

## When
- 并发生产

## Then
- 队列内严格有序
- 等级依据：TEST-C2 RABBITMQ×顺序性=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/go/顺序性/TC-RABBITMQ-GO-ORD-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2
