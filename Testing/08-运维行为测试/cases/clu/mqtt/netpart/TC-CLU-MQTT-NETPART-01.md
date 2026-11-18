# TC-CLU-MQTT-NETPART-01：MQTT 集群桥接分区

> **维度**：系统=MQTT | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 2 节点 EMQX 桥接集群

## When

- 断开节点间集群链路

## Then

- 各分区独立服务（可能产生消息分叉）
- 桥接/集群策略决定是否允许 minority 写
- 恢复后需按策略合并会话

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/mqtt/netpart/TC-CLU-MQTT-NETPART-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
