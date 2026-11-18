# TC-PULSAR-RS-TRX-01：RS 客户端的 PULSAR 事务 用例

> **维度**：系统=PULSAR | 语言=RS | 特性=TRX(事务) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 事务格
> **环境**：E2 docker；**状态**：pending

## Given
- 事务（2.8+）

## When
- 跨分区事务

## Then
- 提交/中止语义（01-63 对照）
- 等级依据：TEST-C2 PULSAR×事务=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/rs/事务/TC-PULSAR-RS-TRX-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 ●
