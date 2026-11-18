# TC-KAFKA-TS-RET-01：TS 客户端的 KAFKA 重试退避 用例

> **维度**：系统=KAFKA | 语言=TS | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- delivery.timeout.ms+retries（无退避）

## When
- 持续 nack 场景

## Then
- 重试次数可观测；无退避声明（等级◐依据）
- 等级依据：TEST-C2 KAFKA×重试退避=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/ts/重试退避/TC-KAFKA-TS-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66/02-16
