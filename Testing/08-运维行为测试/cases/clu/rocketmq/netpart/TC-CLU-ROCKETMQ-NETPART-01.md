# TC-CLU-ROCKETMQ-NETPART-01：RocketMQ namesrv 分区

> **维度**：系统=ROCKETMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 2 namesrv 集群（无共识）

## When

- 隔离 1 namesrv

## Then

- broker 向存活 namesrv 注册
- producer 仍可从任一 namesrv 拉取路由
- namesrv 无状态，恢复后自动同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-ROCKETMQ-NETPART-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
