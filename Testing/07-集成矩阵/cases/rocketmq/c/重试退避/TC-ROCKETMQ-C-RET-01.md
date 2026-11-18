# TC-ROCKETMQ-C-RET-01：C 客户端的 ROCKETMQ 重试退避 用例

> **维度**：系统=ROCKETMQ | 语言=C | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- consumer 重试等级（%RETRY%）

## When
- 消费失败

## Then
- 重试 16 次梯度（◐）
- 等级依据：TEST-C2 ROCKETMQ×重试退避=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rocketmq/c/重试退避/TC-ROCKETMQ-C-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】
