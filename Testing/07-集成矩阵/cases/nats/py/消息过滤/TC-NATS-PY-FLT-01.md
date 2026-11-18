# TC-NATS-PY-FLT-01：PY 客户端的 NATS 消息过滤 用例

> **维度**：系统=NATS | 语言=PY | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given

- subject 通配符

## When

- 模式订阅

## Then

- 通配匹配正确
- 等级依据：TEST-C2 NATS×消息过滤=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/消息过滤/TC-NATS-PY-FLT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66 ●
