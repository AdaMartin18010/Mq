# TC-RABBITMQ-GO-TRX-01：GO 客户端的 RABBITMQ 事务 用例

> **维度**：系统=RABBITMQ | 语言=GO | 特性=TRX(事务) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 事务格
> **环境**：E2 docker；**状态**：pending

## Given
- AMQP tx 单消息事务

## When
- 多消息原子需求

## Then
- 无跨消息事务——应用层模式（等级○）
- 等级依据：TEST-C2 RABBITMQ×事务=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/go/事务/TC-RABBITMQ-GO-TRX-01.sh   # 计划打印（挂账）
```

## 关联
- 01-42/01-63
