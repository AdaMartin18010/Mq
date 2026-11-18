# TC-NATS-RS-DEP-01：RS 客户端的 NATS 部署形态 用例

> **维度**：系统=NATS | 语言=RS | 特性=DEP(部署形态) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- 单节点/JetStream 集群

## When
- 起停

## Then
- 拓扑变更行为

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/rs/部署形态/TC-NATS-RS-DEP-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67
