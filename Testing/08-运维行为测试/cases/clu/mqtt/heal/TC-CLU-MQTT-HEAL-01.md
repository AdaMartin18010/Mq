# TC-CLU-MQTT-HEAL-01：MQTT 集群分区愈合后会话收敛

> **维度**：系统=MQTT | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 2 节点集群分区后愈合

## When

- cleanSession=false 客户端重连

## Then

- 会话元数据按集群策略合并或保留 majority
- 未确认 QoS1/2 消息不重复/不丢失
- 共享订阅状态一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/mqtt/heal/TC-CLU-MQTT-HEAL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
