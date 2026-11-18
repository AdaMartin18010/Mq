# TC-ROCKETMQ-GO-BCK-01：GO 客户端的 ROCKETMQ 背压 用例

> **维度**：系统=ROCKETMQ | 语言=GO | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given

- 消费限流/暂停

## When

- 慢消费

## Then

- 限流生效（◐）
- 等级依据：TEST-C2 ROCKETMQ×背压=◐

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/go/背压/TC-ROCKETMQ-GO-BCK-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
