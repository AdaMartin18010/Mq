# TC-OPS-KAFKA-DYNCONFIG-01：KAFKA 动态配置域 运维行为测试

> **维度**：系统=KAFKA | 行为=DYNCONFIG（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 逐配置项 alter 测试

## When
- 回读

## Then
- 动态域清单与 03-67 画像一致
- 需重启项正确拒绝

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/kafka/dynconfig/TC-OPS-KAFKA-DYNCONFIG-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
