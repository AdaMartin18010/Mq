# TC-REDIS-RS-ORD-01：RS 客户端的 REDIS 顺序性 用例

> **维度**：系统=REDIS | 语言=RS | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given

- Stream ID 单调

## When

- 乱序 XADD

## Then

- ID 单调序
- 等级依据：TEST-C2 REDIS×顺序性=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/rs/顺序性/TC-REDIS-RS-ORD-01.sh   # 计划打印（挂账）
```

## 关联

- TEST-C2 ●
