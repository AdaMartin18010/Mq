# TC-SYN-KAFKA-RACK-01：KAFKA replica placement + 机架感知 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（replica placement + 机架感知）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 ISR / §1.61.7 故障推演
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- RF=3 跨 3 个 rack（broker.rack）

## When

- broker 故障触发重选/再平衡

## Then

- replica placement 满足 rack 感知约束（同分区副本分布于不同 rack）
- leader 重选优先选择不同 rack 的副本
- rebalance 后 under-replicated 归零

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-KAFKA-RACK-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.2 ISR / §1.61.7 故障推演；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
