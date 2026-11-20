# TC-CLU-RABBITMQ-GRACEFUL-EXIT-01：RabbitMQ 节点优雅退役

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点镜像队列集群

## When

- rabbitmqctl stop_app 后退役

## Then

- 镜像队列在剩余节点选出新 master
- 正在 confirm 的消息完成
- 无未处理连接

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-RABBITMQ-GRACEFUL-EXIT-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-65/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
