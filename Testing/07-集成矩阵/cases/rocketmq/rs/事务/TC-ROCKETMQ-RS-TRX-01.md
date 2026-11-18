# TC-ROCKETMQ-RS-TRX-01：RS 客户端的 ROCKETMQ 事务 用例

> **维度**：系统=ROCKETMQ | 语言=RS | 特性=TRX(事务) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 事务格
> **环境**：E2 docker；**状态**：pending

## Given

- half message+回查

## When

- 事务消息

## Then

- 提交/回滚语义（01-63 对照）
- 等级依据：TEST-C2 ROCKETMQ×事务=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/rs/事务/TC-ROCKETMQ-RS-TRX-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
