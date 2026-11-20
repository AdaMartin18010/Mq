# TC-FAL-ROCKETMQ-SYNCROLE-01：ROCKETMQ 主从同步角色切换 运维行为测试

> **维度**：系统=ROCKETMQ | 域=FAL（主从同步角色切换）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RocketMQ 语义对照【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 手动将 slave 提升为 master（brokerRole 变更 + namesrv 注册）

## When
- 原 master 恢复后作为 slave 挂回

## Then
- 角色切换后客户端路由表更新，生产可继续
- 原 master 同步新 master 增量
- 脑裂防护：namesrv 维护 brokerId=0 唯一；同时存在两个 brokerId=0 时告警
- 数据一致性：切换前后消费位点 offset 不跳跃

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-ROCKETMQ-SYNCROLE-01   # 计划打印（dry-run RC=0）
```

## 关联
- 01-63 §1.63.7 RocketMQ 语义对照【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
