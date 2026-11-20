# TC-OPS-MQTT-MSGSIZE-01：MQTT 消息大小上限 运维行为测试

> **维度**：系统=MQTT | 行为=MSGSIZE（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/01-72
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 超 maximum-packet-size（v5 属性）

## When

- CONNECT/PUBLISH

## Then

- 拒绝+0x95（01-64）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-MQTT-MSGSIZE-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-64/01-72；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
