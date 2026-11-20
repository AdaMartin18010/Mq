# TC-CLU-ROCKETMQ-FORCE-EXIT-01：RocketMQ broker 强制退出

> **维度**：系统=ROCKETMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 2 broker 集群

## When

- kill -9 1 broker

## Then

- namesrv 路由表仍保留直至心跳超时
- producer 缓存导致部分消息发送失败
- 客户端更新路由后恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-ROCKETMQ-FORCE-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
