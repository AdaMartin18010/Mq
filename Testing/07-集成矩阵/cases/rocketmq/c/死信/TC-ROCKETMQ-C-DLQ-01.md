# TC-ROCKETMQ-C-DLQ-01：C 客户端的 ROCKETMQ 死信 用例

> **维度**：系统=ROCKETMQ | 语言=C | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given

- 重试耗尽→%DLQ%

## When

- 毒消息

## Then

- 进死信组+人工可捞
- 等级依据：TEST-C2 ROCKETMQ×死信=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/c/死信/TC-ROCKETMQ-C-DLQ-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
