# TC-CLU-ROCKETMQ-GRACEFUL-EXIT-01：RocketMQ broker 优雅退役

> **维度**：系统=ROCKETMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 2 broker 集群

## When
- 停止 broker，namesrv 注销路由

## Then
- namesrv 路由表移除该 broker
- producer 缓存刷新后不再发送
- 在途消息完成

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/clu/rocketmq/graceful-exit/TC-CLU-ROCKETMQ-GRACEFUL-EXIT-01.sh   # 计划打印（挂账）
```

## 关联
- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
