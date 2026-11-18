# TC-REDIS-C-BCK-01：C 客户端的 REDIS 背压 用例

> **维度**：系统=REDIS | 语言=C | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given

- 无原生背压

## When

- 洪峰

## Then

- 轮询补偿模式（01-66）
- 等级依据：TEST-C2 REDIS×背压=○

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/c/背压/TC-REDIS-C-BCK-01.sh   # 计划打印（挂账）
```

## 关联

- ○
