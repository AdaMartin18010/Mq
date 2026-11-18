# TC-FAL-NATS-METALEADER-01：NATS JetStream meta leader 切换 运维行为测试

> **维度**：系统=NATS | 域=FAL（JetStream meta leader 切换）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- JetStream 元数据 leader（meta leader）step-down

## When
- 创建 stream / 更新 consumer

## Then
- 元数据操作在 Raft 选举后恢复，只读窗口≤5s【估算】
- stream ownership 无悬挂
- 脑裂防护：meta group Raft 多数派
- 数据一致性：所有 stream/consumer 状态切换后一致

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/nats/TC-FAL-NATS-METALEADER-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
