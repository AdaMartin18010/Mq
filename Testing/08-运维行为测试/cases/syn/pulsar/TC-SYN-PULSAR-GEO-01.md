# TC-SYN-PULSAR-GEO-01：PULSAR geo-replication 断连恢复 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（geo-replication 断连恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.4 分层存储 / 01-63 §1.63.1 交付语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 两个 Pulsar 集群间开启 geo-replication

## When

- 集群间网络分区后恢复

## Then

- 断连期间消息在本地集群保留，恢复后按 replication backlog 回放
- 冲突行为可配置（last-write-wins / timestamp）
- 不丢已发布消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/pulsar/TC-SYN-PULSAR-GEO-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.4 分层存储 / 01-63 §1.63.1 交付语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
