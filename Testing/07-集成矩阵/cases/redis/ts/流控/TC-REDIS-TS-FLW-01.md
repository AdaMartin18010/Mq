# TC-REDIS-TS-FLW-01：TS 客户端的 REDIS 流控 用例

> **维度**：系统=REDIS | 语言=TS | 特性=FLW(流控) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 流控格
> **环境**：E2 docker；**状态**：pending

## Given

- 无流控

## When

- 过载

## Then

- 应用层限流模式
- 等级依据：TEST-C2 REDIS×流控=○

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/ts/流控/TC-REDIS-TS-FLW-01.sh   # 计划打印（挂账）
```

## 关联

- ○
