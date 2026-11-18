# TC-OPS-MQTT-RECONNSTORM-01：MQTT 重连风暴 运维行为测试

> **维度**：系统=MQTT | 行为=RECONNSTORM（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-46/04-03
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 十万设备重连风暴（弱网回放）

## When
- 曲线

## Then
- 重连雪崩防护

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/mqtt/reconnstorm/TC-OPS-MQTT-RECONNSTORM-01.sh   # 计划打印（挂账）
```

## 关联
- 01-46/04-03；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
