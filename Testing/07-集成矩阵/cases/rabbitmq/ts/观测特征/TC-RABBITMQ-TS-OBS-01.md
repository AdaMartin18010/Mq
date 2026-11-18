# TC-RABBITMQ-TS-OBS-01：TS 客户端的 RABBITMQ 观测特征 用例

> **维度**：系统=RABBITMQ | 语言=TS | 特性=OBS(观测特征) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given
- rabbitmqctl/metrics

## When
- 常态

## Then
- 队列深度/ Erlang scheduler 基线

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rabbitmq/ts/观测特征/TC-RABBITMQ-TS-OBS-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68
