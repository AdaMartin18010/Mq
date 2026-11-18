# TC-ROCKETMQ-C-PST-01：C 客户端的 ROCKETMQ 持久化 用例

> **维度**：系统=ROCKETMQ | 语言=C | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given

- commitlog+consumequeue

## When

- 重启

## Then

- 消息存活
- 等级依据：TEST-C2 ROCKETMQ×持久化=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/c/持久化/TC-ROCKETMQ-C-PST-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
