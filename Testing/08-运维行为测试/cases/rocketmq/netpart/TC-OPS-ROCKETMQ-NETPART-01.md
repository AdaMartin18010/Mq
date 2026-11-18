# TC-OPS-ROCKETMQ-NETPART-01：ROCKETMQ 网络分区 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=NETPART（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 隔离 broker 组

## When
- 路由

## Then
- namesrv 路由冻结
- 恢复收敛

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rocketmq/netpart/TC-OPS-ROCKETMQ-NETPART-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
