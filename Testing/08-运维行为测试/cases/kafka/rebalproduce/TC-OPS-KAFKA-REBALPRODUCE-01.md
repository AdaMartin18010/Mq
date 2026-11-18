# TC-OPS-KAFKA-REBALPRODUCE-01：KAFKA 再平衡期间生产 运维行为测试

> **维度**：系统=KAFKA | 行为=REBALPRODUCE（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-75 陷阱节
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 消费组运行中新增成员 3 次

## When
- 持续生产

## Then
- 生产不中断
- 重平衡时长≤max.poll.interval 窗口

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/rebalproduce/TC-OPS-KAFKA-REBALPRODUCE-01.sh   # 计划打印（挂账）
```

## 关联
- 01-75 陷阱节；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
