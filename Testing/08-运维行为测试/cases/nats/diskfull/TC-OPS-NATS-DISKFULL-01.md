# TC-OPS-NATS-DISKFULL-01：NATS 磁盘满 运维行为测试

> **维度**：系统=NATS | 行为=DISKFULL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- JetStream 存储目录填满

## When
- 发布

## Then
- JetStream API 报错（存储错误）
- Core 发布不受影响（对照）

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/nats/diskfull/TC-OPS-NATS-DISKFULL-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
