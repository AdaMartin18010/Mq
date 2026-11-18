# TC-OPS-KAFKA-METALOSS-01：KAFKA 元数据/控制器丢失 运维行为测试

> **维度**：系统=KAFKA | 行为=METALOSS（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 KRaft 节
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- kill KRaft 控制器（单控）

## When
- 元数据操作

## Then
- 元数据只读窗口
- 重启后快照+日志回放一致
- __cluster_metadata 校验和

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/metaloss/TC-OPS-KAFKA-METALOSS-01.sh   # 计划打印（挂账）
```

## 关联
- 01-61 KRaft 节；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
