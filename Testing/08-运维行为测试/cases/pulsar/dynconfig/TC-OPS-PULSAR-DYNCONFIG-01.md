# TC-OPS-PULSAR-DYNCONFIG-01：PULSAR 动态配置域 运维行为测试

> **维度**：系统=PULSAR | 行为=DYNCONFIG（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 动态配置域核对

## When
- 回读

## Then
- 对照 03-67 画像

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/pulsar/dynconfig/TC-OPS-PULSAR-DYNCONFIG-01.sh   # 计划打印（挂账）
```

## 关联
- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
