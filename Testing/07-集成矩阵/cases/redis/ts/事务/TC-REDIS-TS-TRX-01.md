# TC-REDIS-TS-TRX-01：TS 客户端的 REDIS 事务 用例

> **维度**：系统=REDIS | 语言=TS | 特性=TRX(事务) | 转换链=T4
> **矩阵等级**：— none（反向用例（系统不承诺，防误用））| **断言源**：TEST-C2 事务格
> **环境**：E2 docker；**状态**：pending

## Given
- 无事务

## When
- 事务需求

## Then
- 反向用例——Lua 原子替代
- 等级依据：TEST-C2 REDIS×事务=—

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/redis/ts/事务/TC-REDIS-TS-TRX-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 —
