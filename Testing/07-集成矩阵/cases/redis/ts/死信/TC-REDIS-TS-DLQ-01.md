# TC-REDIS-TS-DLQ-01：TS 客户端的 REDIS 死信 用例

> **维度**：系统=REDIS | 语言=TS | 特性=DLQ(死信) | 转换链=T4
> **矩阵等级**：— none（反向用例（系统不承诺，防误用））| **断言源**：TEST-C2 死信格
> **环境**：E2 docker；**状态**：pending

## Given

- 无原生 DLQ

## When

- 毒消息

## Then

- 反向用例：XAUTOCLAIM 模式为应用层（等级—）
- 等级依据：TEST-C2 REDIS×死信=—

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/ts/死信/TC-REDIS-TS-DLQ-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65
