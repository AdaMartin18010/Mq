# TC-RABBITMQ-RS-PST-01：RS 客户端的 RABBITMQ 持久化 用例

> **维度**：系统=RABBITMQ | 语言=RS | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given
- durable 声明矩阵

## When
- 重启

## Then
- 队列+消息存活
- 等级依据：TEST-C2 RABBITMQ×持久化=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/rs/持久化/TC-RABBITMQ-RS-PST-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68
