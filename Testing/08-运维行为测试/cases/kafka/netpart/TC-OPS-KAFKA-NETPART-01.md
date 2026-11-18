# TC-OPS-KAFKA-NETPART-01：KAFKA 网络分区 运维行为测试

> **维度**：系统=KAFKA | 行为=NETPART（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68/conformance-matrix
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- iptables 隔离 leader 与 2 副本

## When
- 持续生产 acks=all

## Then
- 分区不可用窗口=min.insync 失守
- 恢复后 leader epoch 递增无数据分歧（Jepsen 边界）

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/netpart/TC-OPS-KAFKA-NETPART-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68/conformance-matrix；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
