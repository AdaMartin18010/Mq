# TC-NATS-PY-BCK-01：PY 客户端的 NATS 背压 用例

> **维度**：系统=NATS | 语言=PY | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given

- maxAckPending=100 不 ack

## When

- 持续投递

## Then

- 平台期=100（ASE-010）
- 等级依据：TEST-C2 NATS×背压=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/背压/TC-NATS-PY-BCK-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66/TC-NATS-GO-BCK-01
