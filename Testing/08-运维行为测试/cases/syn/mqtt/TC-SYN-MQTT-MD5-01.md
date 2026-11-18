# TC-SYN-MQTT-MD5-01：MQTT 副本内容一致性 运维行为测试

> **维度**：系统=MQTT | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 持久会话/retained 消息写入固定集合

## When

- broker 重启后读取

## Then

- retained 消息 payload md5 一致
- 持久会话 QoS1/2 未 ack 消息顺序一致
- round-trip 后无消息丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/mqtt/TC-SYN-MQTT-MD5-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
