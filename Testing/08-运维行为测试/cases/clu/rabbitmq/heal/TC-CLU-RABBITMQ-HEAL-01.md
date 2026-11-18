# TC-CLU-RABBITMQ-HEAL-01：RabbitMQ 分区愈合后镜像同步

> **维度**：系统=RABBITMQ | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-65/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 镜像队列经历 pause_minority 后恢复

## When

- 重新启用应用并同步

## Then

- mirror 与 master 同步完成
- 无未同步消息暴露给消费者
- ha-sync-mode=automatic 时自动同步

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/rabbitmq/heal/TC-CLU-RABBITMQ-HEAL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-65/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
