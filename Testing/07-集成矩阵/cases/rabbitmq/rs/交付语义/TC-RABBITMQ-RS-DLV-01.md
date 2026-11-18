# TC-RABBITMQ-RS-DLV-01：RS 客户端的 RABBITMQ 交付语义 用例

> **维度**：系统=RABBITMQ | 语言=RS | 特性=DLV(交付语义) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 交付语义格
> **环境**：E2 docker；**状态**：pending

## Given
- durable queue+persistent 消息+confirm

## When
- broker 重启

## Then
- 消息存活（ASE-015 族）
- confirm 返回即承诺
- 等级依据：TEST-C2 RABBITMQ×交付语义=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/rs/交付语义/TC-RABBITMQ-RS-DLV-01.sh   # 计划打印（挂账）
```

## 关联
- 01-65
