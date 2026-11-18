# TC-PULSAR-TS-RET-01：TS 客户端的 PULSAR 重试退避 用例

> **维度**：系统=PULSAR | 语言=TS | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given
- negative ack 延迟重投

## When
- 失败重投

## Then
- 重投延迟可配
- 等级依据：TEST-C2 PULSAR×重试退避=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/ts/重试退避/TC-PULSAR-TS-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66 ●
