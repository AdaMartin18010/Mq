# TC-PULSAR-C-PST-01：C 客户端的 PULSAR 持久化 用例

> **维度**：系统=PULSAR | 语言=C | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given
- 持久/非持久 topic 对照

## When
- 重启

## Then
- 持久 topic 存活
- 等级依据：TEST-C2 PULSAR×持久化=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/c/持久化/TC-PULSAR-C-PST-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62
