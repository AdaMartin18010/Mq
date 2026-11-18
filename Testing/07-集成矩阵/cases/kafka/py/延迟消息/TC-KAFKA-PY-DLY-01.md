# TC-KAFKA-PY-DLY-01：PY 客户端的 KAFKA 延迟消息 用例

> **维度**：系统=KAFKA | 语言=PY | 特性=DLY(延迟消息) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 延迟消息格
> **环境**：E2 docker；**状态**：pending

## Given
- 无原生；定时任务模拟

## When
- 延迟投递需求

## Then
- 应用层调度器模式断言
- 等级依据：TEST-C2 KAFKA×延迟消息=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/py/延迟消息/TC-KAFKA-PY-DLY-01.sh   # 计划打印（挂账）
```

## 关联
- 02-16/TEST-C2 ○
