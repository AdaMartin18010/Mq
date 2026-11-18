# TC-KAFKA-PY-DEP-01：PY 客户端的 KAFKA 部署形态 用例

> **维度**：系统=KAFKA | 语言=PY | 特性=DEP(部署形态) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- KRaft 单节点/集群compose

## When
- 起停拓扑

## Then
- 启动序列符合 03-68

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/py/部署形态/TC-KAFKA-PY-DEP-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67/03-68
