# TC-CLU-MQTT-JOIN-01：MQTT 集群节点加入

> **维度**：系统=MQTT | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- EMQX/HiveMQ 2 节点

## When

- 加入第三节点

## Then

- 节点列表显示 3 nodes
- 会话按策略分布
- 共享订阅跨节点负载均衡

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-MQTT-JOIN-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-64/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
