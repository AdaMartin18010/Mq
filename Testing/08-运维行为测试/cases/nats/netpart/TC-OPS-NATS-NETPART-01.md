# TC-OPS-NATS-NETPART-01：NATS 网络分区 运维行为测试

> **维度**：系统=NATS | 行为=NETPART（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- supercluster 链路分区

## When
- 路由

## Then
- 孤立集群独立服务
- 恢复后兴趣同步

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/nats/netpart/TC-OPS-NATS-NETPART-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
