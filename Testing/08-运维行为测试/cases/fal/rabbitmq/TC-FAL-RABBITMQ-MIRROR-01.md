# TC-FAL-RABBITMQ-MIRROR-01：RABBITMQ 经典镜像队列提升 运维行为测试

> **维度**：系统=RABBITMQ | 域=FAL（经典镜像队列提升）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 六系统语义能力对照 / 01-61 §1.61.2 复制协议（镜像工程类比）
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 经典镜像队列（ha-mode:exactly）kill master 节点

## When
- slave 提升

## Then
- promoted slave 接管，未同步消息数量可观测
- 脑裂防护：cluster_partition_handling=pause_minority 时 minority 分区暂停写；=autoheal 需人工确认对账
- 数据一致性：持久化镜像消息在存活副本上 md5 一致；非持久化消息丢失符合声明

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-RABBITMQ-MIRROR-01   # 计划打印（dry-run RC=0）
```

## 关联
- 01-63 §1.63.7 六系统语义能力对照 / 01-61 §1.61.2 复制协议（镜像工程类比）；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
