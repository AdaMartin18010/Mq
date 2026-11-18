# TC-NATS-PY-RET-01：PY 客户端的 NATS 重试退避 用例

> **维度**：系统=NATS | 语言=PY | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- maxDeliver+backoff 序列

## When
- 持续失败

## Then
- 退避逐档断言（ASE-006）
- 等级依据：TEST-C2 NATS×重试退避=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/py/重试退避/TC-NATS-PY-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66 ●
