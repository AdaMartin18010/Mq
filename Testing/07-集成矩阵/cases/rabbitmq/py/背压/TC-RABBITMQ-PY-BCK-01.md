# TC-RABBITMQ-PY-BCK-01：PY 客户端的 RABBITMQ 背压 用例

> **维度**：系统=RABBITMQ | 语言=PY | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given
- basic.qos prefetch

## When
- 慢消费

## Then
- 未确认数=平台期
- 等级依据：TEST-C2 RABBITMQ×背压=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/py/背压/TC-RABBITMQ-PY-BCK-01.sh   # 计划打印（挂账）
```

## 关联
- ASE-011
