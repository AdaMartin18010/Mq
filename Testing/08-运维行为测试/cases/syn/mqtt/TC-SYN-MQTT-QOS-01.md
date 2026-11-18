# TC-SYN-MQTT-QOS-01：MQTT QoS0/1/2 语义 运维行为测试

> **维度**：系统=MQTT | 域=SYN（QoS0/1/2 语义）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.1 / §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- MQTT 3.1.1/5.0 客户端分别用 QoS0/1/2 发布

## When

- broker 回传 PUBACK/PUBREC/PUBCOMP

## Then

- QoS0 无 ack（at-most-once）；QoS1 at-least-once；QoS2 协议级 exactly-once
- QoS2 通过四次握手去重
- 行为符合 01-63 §1.63.1 交付语义

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/mqtt/TC-SYN-MQTT-QOS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.1 / §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
