# TC-FAL-ROCKETMQ-MASTERFAIL-01：ROCKETMQ broker 主从切换 运维行为测试

> **维度**：系统=ROCKETMQ | 域=FAL（broker 主从切换）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- broker 主从部署（master-slave sync_flush）kill master

## When
- slave 提升

## Then
- slave 在 namesrv 路由更新后承接写，RTO≤30s【估算】【论证】
- 已 commit 消息（同步复制）在 slave 上可读
- 脑裂防护：namesrv 路由仲裁 + HA 地址唯一；分区期间仅 majority 侧可写
- 数据一致性：同步复制下 master/slave commitlog 一致；异步复制下未同步消息可观测

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-ROCKETMQ-MASTERFAIL-01   # 计划打印（dry-run RC=0）
```

## 关联
- 01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
