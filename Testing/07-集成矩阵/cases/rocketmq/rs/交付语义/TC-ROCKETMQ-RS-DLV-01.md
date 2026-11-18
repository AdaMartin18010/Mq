# TC-ROCKETMQ-RS-DLV-01：RS 客户端的 ROCKETMQ 交付语义 用例

> **维度**：系统=ROCKETMQ | 语言=RS | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given

- commitlog 持久化+消费确认

## When

- broker 宕机恢复

## Then

- 已确认消息不丢
- 等级依据：TEST-C2 ROCKETMQ×交付语义=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/rs/交付语义/TC-ROCKETMQ-RS-DLV-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】版本核实入季度复核
