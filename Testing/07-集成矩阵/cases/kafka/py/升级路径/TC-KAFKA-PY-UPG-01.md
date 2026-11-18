# TC-KAFKA-PY-UPG-01：PY 客户端的 KAFKA 升级路径 用例

> **维度**：系统=KAFKA | 语言=PY | 特性=UPG(升级路径) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 滚动升级路径

## When
- 版本跳转

## Then
- 升级预检（skill mq-ops-kafka-upgrade）

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/py/升级路径/TC-KAFKA-PY-UPG-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67/AI_Skills
