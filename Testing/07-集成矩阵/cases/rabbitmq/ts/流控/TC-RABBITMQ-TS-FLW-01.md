# TC-RABBITMQ-TS-FLW-01：TS 客户端的 RABBITMQ 流控 用例

> **维度**：系统=RABBITMQ | 语言=TS | 特性=FLW(流控) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 流控格
> **环境**：E2 docker；**状态**：pending

## Given
- credit flow（AMQP 1.0）

## When
- 过载

## Then
- 信用耗尽行为可观测
- 等级依据：TEST-C2 RABBITMQ×流控=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/ts/流控/TC-RABBITMQ-TS-FLW-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66
