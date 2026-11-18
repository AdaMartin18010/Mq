# TC-NATS-PY-OBS-01：PY 客户端的 NATS 观测特征 用例

> **维度**：系统=NATS | 语言=PY | 特性=OBS(观测特征) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given

- /varz+consumer info

## When

- 常态

## Then

- JetStream 指标基线

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/观测特征/TC-NATS-PY-OBS-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68
