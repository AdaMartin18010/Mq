# TC-OPS-MQTT-CONNLIMIT-01：MQTT 连接数上限 运维行为测试

> **维度**：系统=MQTT | 行为=CONNLIMIT（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- max_connections 风暴

## When

- 连接

## Then

- 拒绝行为

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/mqtt/connlimit/TC-OPS-MQTT-CONNLIMIT-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
