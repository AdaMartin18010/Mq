# TC-NATS-PY-FLW-01：PY 客户端的 NATS 流控 用例

> **维度**：系统=NATS | 语言=PY | 特性=FLW(流控) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 流控格
> **环境**：E2 docker；**状态**：pending

## Given

- pending limits

## When

- 洪峰

## Then

- 限额行为可观测
- 等级依据：TEST-C2 NATS×流控=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/流控/TC-NATS-PY-FLW-01.sh   # 计划打印（挂账）
```

## 关联

- TEST-C2 ●
