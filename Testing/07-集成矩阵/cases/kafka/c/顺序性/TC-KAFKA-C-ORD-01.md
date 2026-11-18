# TC-KAFKA-C-ORD-01：C 客户端的 KAFKA 顺序性 用例

> **维度**：系统=KAFKA | 语言=C | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given
- 单分区 topic；并发 3 生产者

## When
- 产 1000 条

## Then
- 分区内消费序=偏移序
- 跨分区无序合法
- 等级依据：TEST-C2 KAFKA×顺序性=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/c/顺序性/TC-KAFKA-C-ORD-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61/TEST-C2 顺序性
