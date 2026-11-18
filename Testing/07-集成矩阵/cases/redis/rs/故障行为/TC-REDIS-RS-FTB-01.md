# TC-REDIS-RS-FTB-01：RS 客户端的 REDIS 故障行为 用例

> **维度**：系统=REDIS | 语言=RS | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given

- 内存满 eviction

## When

- 注入

## Then

- 驱逐策略行为（03-68 OOM 前兆）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/rs/故障行为/TC-REDIS-RS-FTB-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68
