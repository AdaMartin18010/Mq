# TC-CLU-PULSAR-NETPART-01：Pulsar Metadata Store 分区

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.7
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 ZooKeeper/Oxia

## When

- 隔离 1 节点

## Then

- 多数派继续提供元数据服务
- 少数派不可写，broker 连接可能失败
- ledger 元数据无法更新导致新 ledger 创建失败

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/pulsar/netpart/TC-CLU-PULSAR-NETPART-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.7；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
