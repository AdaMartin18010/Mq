# TC-CLU-NATS-NETPART-01：NATS 集群无脑裂声明

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 JetStream R3

## When

- 分区使 1 节点孤立

## Then

- 孤立节点无法构成 quorum，停止 JetStream 写
- 多数派侧继续服务
- 恢复后通过 RAFT 日志合并

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-NATS-NETPART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
