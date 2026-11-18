# TC-RABBITMQ-PY-RET-01：PY 客户端的 RABBITMQ 重试退避 用例

> **维度**：系统=RABBITMQ | 语言=PY | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- 客户端重连+nack 重投

## When
- 瞬时故障

## Then
- 重投可观测；无退避序列
- 等级依据：TEST-C2 RABBITMQ×重试退避=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/py/重试退避/TC-RABBITMQ-PY-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65
