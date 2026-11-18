# TC-NATS-RS-DLY-01：RS 客户端的 NATS 延迟消息 用例

> **维度**：系统=NATS | 语言=RS | 特性=DLY(延迟消息) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 延迟消息格
> **环境**：E2 docker；**状态**：pending

## Given
- 无原生延迟

## When
- 定时需求

## Then
- 应用层调度模式
- 等级依据：TEST-C2 NATS×延迟消息=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/rs/延迟消息/TC-NATS-RS-DLY-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 ○
