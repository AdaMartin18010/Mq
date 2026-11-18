# TC-RABBITMQ-TS-FTB-01：TS 客户端的 RABBITMQ 故障行为 用例

> **维度**：系统=RABBITMQ | 语言=TS | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 内存/磁盘 alarm

## When
- 故障注入

## Then
- alarm 触发的写行为（03-68）

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/ts/故障行为/TC-RABBITMQ-TS-FTB-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68
