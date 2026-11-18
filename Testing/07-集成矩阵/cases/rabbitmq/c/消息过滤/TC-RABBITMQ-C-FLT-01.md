# TC-RABBITMQ-C-FLT-01：C 客户端的 RABBITMQ 消息过滤 用例

> **维度**：系统=RABBITMQ | 语言=C | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given
- routing key+headers+binding

## When
- 多条件路由

## Then
- 绑定键路由正确
- 等级依据：TEST-C2 RABBITMQ×消息过滤=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/c/消息过滤/TC-RABBITMQ-C-FLT-01.sh   # 计划打印（挂账）
```

## 关联
- 02-13
