# TC-SYN-MQTT-BRIDGE-01：MQTT 桥接断连恢复 运维行为测试

> **维度**：系统=MQTT | 域=SYN（桥接断连恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- mosquitto bridge 连接远端 broker

## When

- 桥接链路断开再恢复

## Then

- 断连期间 inflight QoS1/2 消息按 bridge 配置缓冲
- 恢复后按序回放；远端去重由 QoS2 保证
- 不丢已 publish 消息

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/mqtt/TC-SYN-MQTT-BRIDGE-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
