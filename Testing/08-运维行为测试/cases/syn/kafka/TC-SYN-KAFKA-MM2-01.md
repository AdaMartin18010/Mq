# TC-SYN-KAFKA-MM2-01：KAFKA MirrorMaker 2 断连恢复 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（MirrorMaker 2 断连恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.6 保留策略 / 01-63 §1.63.1 交付语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- MM2 单向镜像 source→target

## When

- 断网后恢复

## Then

- source offset 与 target offset 映射关系保持
- 断连期间消息在 source 保留（按 retention），恢复后回放
- 双向镜像时同名 topic 冲突可观测（last-write 或时间戳策略）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-KAFKA-MM2-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61 §1.61.6 保留策略 / 01-63 §1.63.1 交付语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
