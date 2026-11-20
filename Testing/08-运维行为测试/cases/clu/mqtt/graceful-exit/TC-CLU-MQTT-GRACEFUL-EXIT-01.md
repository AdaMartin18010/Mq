# TC-CLU-MQTT-GRACEFUL-EXIT-01：MQTT 集群节点优雅退役

> **维度**：系统=MQTT | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 EMQX

## When

- 节点 leave_cluster

## Then

- 会话迁移到剩余节点
- 共享订阅重新分配
- 已连接客户端触发重连

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-MQTT-GRACEFUL-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-64/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
