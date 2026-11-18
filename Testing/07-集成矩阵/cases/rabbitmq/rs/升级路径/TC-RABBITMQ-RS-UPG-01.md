# TC-RABBITMQ-RS-UPG-01：RS 客户端的 RABBITMQ 升级路径 用例

> **维度**：系统=RABBITMQ | 语言=RS | 特性=UPG(升级路径) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 版本升级

## When
- 蓝绿/滚动

## Then
- 升级窗口行为

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/rs/升级路径/TC-RABBITMQ-RS-UPG-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67
