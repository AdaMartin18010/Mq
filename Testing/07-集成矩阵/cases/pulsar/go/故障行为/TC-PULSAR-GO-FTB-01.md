# TC-PULSAR-GO-FTB-01：GO 客户端的 PULSAR 故障行为 用例

> **维度**：系统=PULSAR | 语言=GO | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- bookie 宕机

## When
- 注入

## Then
- ledger 恢复（01-62 恢复协议实测）

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/go/故障行为/TC-PULSAR-GO-FTB-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62/03-68
