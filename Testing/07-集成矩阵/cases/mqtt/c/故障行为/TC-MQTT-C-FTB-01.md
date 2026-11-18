# TC-MQTT-C-FTB-01：C 客户端的 MQTT 故障行为 用例

> **维度**：系统=MQTT | 语言=C | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 连接风暴

## When
- 注入

## Then
- 连接数上限行为

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/c/故障行为/TC-MQTT-C-FTB-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68
