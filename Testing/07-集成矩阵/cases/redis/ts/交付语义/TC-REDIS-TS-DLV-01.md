# TC-REDIS-TS-DLV-01：TS 客户端的 REDIS 交付语义 用例

> **维度**：系统=REDIS | 语言=TS | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given
- AOF+消费组 PEL

## When
- 消费端重启

## Then
- PEL 重投（应用层承诺）
- 等级依据：TEST-C2 REDIS×交付语义=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/redis/ts/交付语义/TC-REDIS-TS-DLV-01.sh   # 计划打印（挂账）
```

## 关联
- ASE-014
