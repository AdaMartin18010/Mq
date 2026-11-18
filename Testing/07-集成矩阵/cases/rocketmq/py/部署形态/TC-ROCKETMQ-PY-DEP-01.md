# TC-ROCKETMQ-PY-DEP-01：PY 客户端的 ROCKETMQ 部署形态 用例

> **维度**：系统=ROCKETMQ | 语言=PY | 特性=DEP(部署形态) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given

- namesrv+broker 拓扑

## When

- 起停

## Then

- 启动序列（先 namesrv）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/py/部署形态/TC-ROCKETMQ-PY-DEP-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】03-67
