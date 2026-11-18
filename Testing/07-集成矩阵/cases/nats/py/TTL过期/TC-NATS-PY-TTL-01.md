# TC-NATS-PY-TTL-01：PY 客户端的 NATS TTL过期 用例

> **维度**：系统=NATS | 语言=PY | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- maxAge/消息 TTL

## When
- 过期

## Then
- 过期清理可观测
- 等级依据：TEST-C2 NATS×TTL过期=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/py/TTL过期/TC-NATS-PY-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 ●
