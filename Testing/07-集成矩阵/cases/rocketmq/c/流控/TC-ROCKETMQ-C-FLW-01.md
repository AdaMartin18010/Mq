# TC-ROCKETMQ-C-FLW-01：C 客户端的 ROCKETMQ 流控 用例

> **维度**：系统=ROCKETMQ | 语言=C | 特性=FLW(流控) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 流控格
> **环境**：E2 docker；**状态**：pending

## Given
- 消费限流

## When
- 过载

## Then
- 限流行为可观测
- 等级依据：TEST-C2 ROCKETMQ×流控=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rocketmq/c/流控/TC-ROCKETMQ-C-FLW-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】◐
