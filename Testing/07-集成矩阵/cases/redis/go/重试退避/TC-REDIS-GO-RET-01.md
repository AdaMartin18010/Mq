# TC-REDIS-GO-RET-01：GO 客户端的 REDIS 重试退避 用例

> **维度**：系统=REDIS | 语言=GO | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- 应用层重试

## When
- 失败

## Then
- 模式断言
- 等级依据：TEST-C2 REDIS×重试退避=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/redis/go/重试退避/TC-REDIS-GO-RET-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 ○
