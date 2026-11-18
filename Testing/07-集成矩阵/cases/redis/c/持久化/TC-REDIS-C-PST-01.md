# TC-REDIS-C-PST-01：C 客户端的 REDIS 持久化 用例

> **维度**：系统=REDIS | 语言=C | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given

- AOF everysec+RDB

## When

- 重启

## Then

- XLEN 与 ID 保持（ASE-014）
- 等级依据：TEST-C2 REDIS×持久化=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/c/持久化/TC-REDIS-C-PST-01.sh   # 计划打印（挂账）
```

## 关联

- ASE-014
