# TC-ROCKETMQ-GO-ORD-01：GO 客户端的 ROCKETMQ 顺序性 用例

> **维度**：系统=ROCKETMQ | 语言=GO | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given

- 分区顺序消息（MessageQueueSelector）

## When

- 同键生产

## Then

- 键内有序消费
- 等级依据：TEST-C2 ROCKETMQ×顺序性=●

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/go/顺序性/TC-ROCKETMQ-GO-ORD-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
