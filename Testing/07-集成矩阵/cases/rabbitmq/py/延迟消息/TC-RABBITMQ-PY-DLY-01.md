# TC-RABBITMQ-PY-DLY-01：PY 客户端的 RABBITMQ 延迟消息 用例

> **维度**：系统=RABBITMQ | 语言=PY | 特性=DLY(延迟消息) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 延迟消息格
> **环境**：E2 docker；**状态**：pending

## Given
- 延迟插件/TTL+DLX 模式

## When
- 延迟投递

## Then
- 插件模式断言（等级◐）
- 等级依据：TEST-C2 RABBITMQ×延迟消息=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/py/延迟消息/TC-RABBITMQ-PY-DLY-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65/02-16
