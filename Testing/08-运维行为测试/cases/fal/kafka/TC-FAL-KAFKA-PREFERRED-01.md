# TC-FAL-KAFKA-PREFERRED-01：KAFKA preferred leader 恢复 运维行为测试

> **维度**：系统=KAFKA | 域=FAL（preferred leader 恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR/复制协议
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 将分区 leader 迁移至非 preferred replica 后触发 preferred leader election

## When
- kill 当前 leader

## Then
- preferred replica 重新被选举为 leader，RTO≤60s【估算】
- 无 unclean leader election 发生
- 脑裂防护：controller 仲裁，仅 ISR 内 preferred replica 可当选
- 数据一致性：切换前后 HW 不后退

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/kafka/TC-FAL-KAFKA-PREFERRED-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61 §1.61.2 ISR/复制协议；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
