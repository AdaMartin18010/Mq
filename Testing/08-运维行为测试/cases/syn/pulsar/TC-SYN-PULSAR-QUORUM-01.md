# TC-SYN-PULSAR-QUORUM-01：PULSAR AQ=2 vs AQ=3 一致性矩阵 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（AQ=2 vs AQ=3 一致性矩阵）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 E/WQ/AQ 三角关系
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- E=3, WQ=3，分别配置 AQ=2 与 AQ=3

## When

- 注入 1 个慢 bookie

## Then

- AQ=2 时写仍成功，容忍 1 个慢节点；AQ=3 时写失败或长尾
- 读 quorum 比对 2 个副本，结果一致
- 延迟与可用性权衡符合 01-62 配置表

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/pulsar/TC-SYN-PULSAR-QUORUM-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.2 E/WQ/AQ 三角关系；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
