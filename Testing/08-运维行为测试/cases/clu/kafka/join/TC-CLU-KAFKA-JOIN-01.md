# TC-CLU-KAFKA-JOIN-01：单节点→集群扩展与分区重分配

> **维度**：系统=KAFKA | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.4/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 1 broker → 3 broker KRaft 集群，topic RF=3

## When

- 新增 2 broker，执行分区重分配

## Then

- 新 broker 注册到 KRaft metadata
- 重分配后分区副本均匀分布
- UnderReplicatedPartitions=0

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-KAFKA-JOIN-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.4/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
