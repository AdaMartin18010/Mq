# TC-CLU-ROCKETMQ-HEAL-01：RocketMQ 分区愈合后路由收敛

> **维度**：系统=ROCKETMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 与 namesrv 分区恢复

## When

- producer 拉取最新路由

## Then

- broker 重新注册到 namesrv
- producer 路由缓存刷新
- 无长期消息路由黑洞

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-ROCKETMQ-HEAL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
