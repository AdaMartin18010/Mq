# TC-CLU-PULSAR-JOIN-01：Pulsar 集群 bookie 加入

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.6
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 broker + 3 bookie 集群

## When

- 新增 1 bookie

## Then

- bookkeeper listbookies -rw 包含新节点
- 新 ledger ensemble 优先使用新 bookie
- 已有 ledger 不自动迁移（需 decommission）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/pulsar/join/TC-CLU-PULSAR-JOIN-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.6；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
