# TC-CLU-ROCKETMQ-JOIN-01：RocketMQ namesrv/broker 集群加入

> **维度**：系统=ROCKETMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 2 namesrv + 2 broker

## When
- 新增 broker 并注册到 namesrv

## Then
- namesrv 路由表包含新 broker
- producer 缓存刷新后路由到新 broker
- 无单点写入中断

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/clu/rocketmq/join/TC-CLU-ROCKETMQ-JOIN-01.sh   # 计划打印（挂账）
```

## 关联
- 01-67/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
