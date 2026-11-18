# TC-PULSAR-GO-DEP-01：GO 客户端的 PULSAR 部署形态 用例

> **维度**：系统=PULSAR | 语言=GO | 特性=DEP(部署形态) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- broker/bookie 分离拓扑

## When
- 起停

## Then
- 分层启动序列

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/go/部署形态/TC-PULSAR-GO-DEP-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67/01-62
