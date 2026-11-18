# TC-PULSAR-C-DLY-01：C 客户端的 PULSAR 延迟消息 用例

> **维度**：系统=PULSAR | 语言=C | 特性=DLY(延迟消息) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 延迟消息格
> **环境**：E2 docker；**状态**：pending

## Given
- deliverAfter 原生

## When
- 延迟投递

## Then
- 时间窗可见性（ASE-013）
- 等级依据：TEST-C2 PULSAR×延迟消息=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/c/延迟消息/TC-PULSAR-C-DLY-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2 ●
