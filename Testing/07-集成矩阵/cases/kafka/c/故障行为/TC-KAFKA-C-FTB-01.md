# TC-KAFKA-C-FTB-01：C 客户端的 KAFKA 故障行为 用例

> **维度**：系统=KAFKA | 语言=C | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 磁盘满/副本失联

## When
- 故障注入

## Then
- ISR 收缩行为（01-61 推演表实测）

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/c/故障行为/TC-KAFKA-C-FTB-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68/01-61
