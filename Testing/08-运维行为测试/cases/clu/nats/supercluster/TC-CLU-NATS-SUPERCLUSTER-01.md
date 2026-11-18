# TC-CLU-NATS-SUPERCLUSTER-01：NATS Supercluster 分区行为

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 2 区域各 3 节点 JetStream

## When

- 断开 gateways

## Then

- 每个区域独立选举 stream leader
- 区域间消息复制中断
- 恢复后 gateway 重建并补全跨域副本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/nats/supercluster/TC-CLU-NATS-SUPERCLUSTER-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
