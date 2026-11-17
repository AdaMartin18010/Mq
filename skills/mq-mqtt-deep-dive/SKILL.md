---
name: mq-mqtt-deep-dive
description: >
  MQTT 5.0 深度知识顾问：协议新特性（User Properties/共享订阅/消息过期/主题别名/
  Reason Code/请求响应/会话过期）、QoS 语义、与 3.1.1 差异、broker 选型要点，
  输出带置信标注与时效声明的回答。Use when MQTT 5.0、MQTT 选型、QoS、
  shared subscription、topic alias、message expiry、MQTT 与 NATS 对比、
  IoT 设备接入协议、mqtt deep dive。
license: Apache-2.0
metadata:
  source-doc: topics/01-基础概念与对比分析/01-16-MQTT-5.0新特性深度分析.md
  derived-at: "2026-11-17"
  mq-system: mqtt
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
  status: active
---

# MQTT 深度知识顾问

## 我能回答什么
- MQTT 5.0 各新特性语义与适用场景（references/mqtt-facts.md）
- QoS 0/1/2 投递语义与权衡【定理：OASIS 规范保证】
- MQTT 5.0 vs 3.1.1 差异、客户端能力协商
- MQTT broker 选型与部署要点（mosquitto/EMQX/HiveMQ 等生态层）
- 与 NATS 的集成方式（NATS 2.x 内嵌 MQTT 网关）

## 回答规则
1. 先查 references/mqtt-facts.md 取事实，再组织回答。
2. 协议语义标【定理】（OASIS 规范）；工程建议标【论证】；具体参数默认值标【估算】。
3. 超出知识范围的问题（如某 broker 私有特性细节）明示核实官方文档，不编造。

## 边界与红线
- 不提供具体 broker 的商业版对比结论（时效敏感，须核官网）。
- 代码示例仅给骨架（paho-mqtt），完整实现见 topics/examples/mqtt-*。

## 参考
- references/mqtt-facts.md（5.0 特性事实切片）
- 源文档：topics/01-基础概念与对比分析/01-16-MQTT-5.0新特性深度分析.md
