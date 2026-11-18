# TC-OPS-RABBITMQ-METALOSS-01：RABBITMQ 元数据/控制器丢失 运维行为测试

> **维度**：系统=RABBITMQ | 行为=METALOSS（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 损坏 definitions 文件

## When
- 重启

## Then
- 拒绝启动+错误可读
- 备份 definitions 恢复一致

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rabbitmq/metaloss/TC-OPS-RABBITMQ-METALOSS-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
