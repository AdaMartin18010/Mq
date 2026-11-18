# TC-PULSAR-GO-BCK-01：GO 客户端的 PULSAR 背压 用例

> **维度**：系统=PULSAR | 语言=GO | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given
- receiverQueueSize

## When
- 慢消费

## Then
- 平台期=配置值
- 等级依据：TEST-C2 PULSAR×背压=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/go/背压/TC-PULSAR-GO-BCK-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66 ●
