# TC-REDIS-C-IDM-01：C 客户端的 REDIS 幂等去重 用例

> **维度**：系统=REDIS | 语言=C | 特性=IDM(幂等去重) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 幂等去重格
> **环境**：E2 docker；**状态**：pending

## Given

- XADD 应用层去重

## When

- 重复生产

## Then

- 幂等键模式
- 等级依据：TEST-C2 REDIS×幂等去重=○

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/c/幂等去重/TC-REDIS-C-IDM-01.sh   # 计划打印（挂账）
```

## 关联

- TEST-C2 ○
