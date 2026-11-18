# TC-OPS-RABBITMQ-REPLICALOST-01：RABBITMQ 副本失联 运维行为测试

> **维度**：系统=RABBITMQ | 行为=REPLICALOST（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 集群暂停镜像副本

## When
- 发布

## Then
- 镜像降级策略生效
- 恢复后 catchup

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rabbitmq/replicalost/TC-OPS-RABBITMQ-REPLICALOST-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
