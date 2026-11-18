# TC-REDIS-RS-TTL-01：RS 客户端的 REDIS TTL过期 用例

> **维度**：系统=REDIS | 语言=RS | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：— none（反向用例（系统不承诺，防误用））| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given

- 无消息级 TTL

## When

- 过期需求

## Then

- 反向用例——MAXLEN 是容量非时间
- 等级依据：TEST-C2 REDIS×TTL过期=—

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/redis/rs/TTL过期/TC-REDIS-RS-TTL-01.sh   # 计划打印（挂账）
```

## 关联

- TEST-C2 —
