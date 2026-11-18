# TC-NATS-C-PST-01：C 客户端的 NATS 持久化 用例

> **维度**：系统=NATS | 语言=C | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given
- JetStream 持久（Core 内存对照）

## When
- 重启

## Then
- 流数据存活
- 等级依据：TEST-C2 NATS×持久化=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/c/持久化/TC-NATS-C-PST-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66 ◐
