# TC-FAL-KAFKA-KRAFT-01：KAFKA KRaft 控制器转移 运维行为测试

> **维度**：系统=KAFKA | 域=FAL（KRaft 控制器转移）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.4 KRaft 元数据日志
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- KRaft 3 节点 controller quorum，kill active controller

## When

- 并发创建 topic / 分区重分配

## Then

- 新 controller leader 在 Raft 选举超时内产生，元数据只读窗口≤5s【估算】
- __cluster_metadata 日志 offset 连续，快照+回放一致
- 脑裂防护：Raft majority 选举；minority 控制器无法提交元数据
- 数据一致性：已提交元数据变更在切换后仍可见，无悬挂分区

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/fal/kafka/TC-FAL-KAFKA-KRAFT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.4 KRaft 元数据日志；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
