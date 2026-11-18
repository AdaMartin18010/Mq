# TC-KAFKA-RS-TRX-01：RS 客户端的 KAFKA 事务 用例

> **维度**：系统=KAFKA | 语言=RS | 特性=TRX(事务) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 事务格
> **环境**：E2 docker；**状态**：pending

## Given
- 事务生产者+read_committed 消费者

## When
- 跨分区事务提交/中止

## Then
- 仅已提交可见
- 中止事务不可见（Jepsen 边界见 conformance-matrix）
- 等级依据：TEST-C2 KAFKA×事务=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/rs/事务/TC-KAFKA-RS-TRX-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63/KAFKA-17754
