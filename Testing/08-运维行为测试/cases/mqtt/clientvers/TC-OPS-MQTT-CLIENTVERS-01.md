# TC-OPS-MQTT-CLIENTVERS-01：MQTT 版本兼容 运维行为测试

> **维度**：系统=MQTT | 行为=CLIENTVERS（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 3.1.1 与 5.0 客户端混连

## When
- 协议协商

## Then
- CONNACK 版本标识
- v5 属性不被 3.x 误读

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/mqtt/clientvers/TC-OPS-MQTT-CLIENTVERS-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
