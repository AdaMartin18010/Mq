# TC-FAL-MQTT-CLUSTER-01：MQTT MQTT broker 集群/VIP 切换 运维行为测试

> **维度**：系统=MQTT | 域=FAL（MQTT broker 集群/VIP 切换）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- MQTT 双节点 active/standby（共享持久会话存储或负载均衡 VIP）

## When

- VIP 切到 standby

## Then

- cleanSession=false 客户端自动重连，会话继承
- 无重复连接风暴（退避+会话已存在）
- 脑裂防护：共享存储单写或 LB 单主；双 active 时拒绝写
- 数据一致性：离线 QoS1/2 消息在切换后不丢失、不重复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-MQTT-CLUSTER-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
