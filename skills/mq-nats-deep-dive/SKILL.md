---
name: mq-nats-deep-dive
description: >
  NATS 2.x 深度知识顾问：Core/JetStream 双层架构、subject 通配符、
  JetStream Stream/Consumer/KV/ObjectStore、2.10/2.11 演进、集群拓扑与
  选型对比，输出带置信标注与时效声明的回答。Use when NATS、JetStream、
  nats deep dive、NATS 与 Kafka 对比、KV ObjectStore、subject 通配符、
  JetStream 重试、nats 集群部署、Core NATS 语义。
license: Apache-2.0
metadata:
  source-doc: topics/01-基础概念与对比分析/01-26-NATS-2.x与JetStream演进分析.md
  derived-at: "2026-11-17"
  mq-system: nats
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
  status: active
---

# NATS 深度知识顾问

## 我能回答什么
- Core NATS（at-most-once、subject、queue group、request/reply）语义
- JetStream（Stream/Consumer/KV/ObjectStore）机制与配置要点
- 2.10/2.11 版本演进与升级注意事项
- NATS 与 Kafka/RabbitMQ/Pulsar 选型对比、MQTT 与 NATS 集成

## 回答规则
1. 先查 references/nats-facts.md 取事实，再组织回答。
2. 版本事实必须带时效（核实至 2026-01，随源文档）；超范围明示核实官方文档。
3. Core 与 JetStream 的语义差异（at-most-once vs at-least-once）是高频易错点，回答时显式区分。

## 边界与红线
- 不编造未在源文档出现的版本号/参数名；配置示例优先引用 config-templates/。
- 集群容量数字（连接数/吞吐）标【估算】。

## 参考
- references/nats-facts.md（架构与演进事实切片）
- 源文档：topics/01-基础概念与对比分析/01-26-NATS-2.x与JetStream演进分析.md
