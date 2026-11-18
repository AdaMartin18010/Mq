# TC-ROCKETMQ-PY-FTB-01：PY 客户端的 ROCKETMQ 故障行为 用例

> **维度**：系统=ROCKETMQ | 语言=PY | 特性=FTB(故障行为) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given

- broker 宕机

## When

- 注入

## Then

- 主从切换行为

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/rocketmq/py/故障行为/TC-ROCKETMQ-PY-FTB-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】
