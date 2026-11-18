# TC-ROCKETMQ-PY-DLY-01：PY 客户端的 ROCKETMQ 延迟消息 用例

> **维度**：系统=ROCKETMQ | 语言=PY | 特性=DLY(延迟消息) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 延迟消息格
> **环境**：E2 docker；**状态**：pending

## Given
- 18 级延迟等级原生

## When
- 延迟投递

## Then
- 等级时间窗断言
- 等级依据：TEST-C2 ROCKETMQ×延迟消息=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rocketmq/py/延迟消息/TC-ROCKETMQ-PY-DLY-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】●
