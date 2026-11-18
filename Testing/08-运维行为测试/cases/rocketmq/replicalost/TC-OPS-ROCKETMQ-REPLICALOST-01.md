# TC-OPS-ROCKETMQ-REPLICALOST-01：ROCKETMQ 副本失联 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=REPLICALOST（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 停 slave

## When
- 复制

## Then
- 主继续服务

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rocketmq/replicalost/TC-OPS-ROCKETMQ-REPLICALOST-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
