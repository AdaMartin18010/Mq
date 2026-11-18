# TC-OPS-MQTT-NETPART-01：MQTT 网络分区 运维行为测试

> **维度**：系统=MQTT | 行为=NETPART（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 桥接链路分区

## When
- 桥接

## Then
- 离线缓冲/丢弃策略
- 恢复补传

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/mqtt/netpart/TC-OPS-MQTT-NETPART-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
