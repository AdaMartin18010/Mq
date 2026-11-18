# TC-ROCKETMQ-RS-FLT-01：RS 客户端的 ROCKETMQ 消息过滤 用例

> **维度**：系统=ROCKETMQ | 语言=RS | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given

- SQL92 过滤表达式

## When

- 条件消费

## Then

- 过滤表达式生效
- 等级依据：TEST-C2 ROCKETMQ×消息过滤=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/rs/消息过滤/TC-ROCKETMQ-RS-FLT-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
