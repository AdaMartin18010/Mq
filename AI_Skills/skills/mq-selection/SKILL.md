---
name: mq-selection
description: >
  论证并推荐消息队列技术选型方案：按场景（日志聚合/IoT/微服务/任务队列/事件流/
  实时通信/大数据/移动推送）、硬约束（吞吐/延迟/顺序/事务/持久化/多租户/运维成本）
  输出带置信标注的选型建议与备选方案。
  行为约束：用户未提供场景与硬约束时，必须先回问约束清单（禁止在无约束输入下直接给单一推荐）。Use when 技术选型、选 Kafka 还是
  Pulsar/NATS/RabbitMQ/Redis/MQTT、message broker selection、MQ 对比论证、
  消息队列选型、替换成替代方案评估、broker comparison、数据契约选型、
  流处理选型、事件驱动架构选型、AsyncAPI 选型、AI Agent 消息层。
license: Apache-2.0
metadata:
  source-doc: |
    topics/01-基础概念与对比分析/01-03-决策图网分析.md
    topics/01-基础概念与对比分析/01-19-选型决策矩阵.md
    topics/01-基础概念与对比分析/01-20-技术选型速查表.md
  derived-at: "2026-11-18"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-18"
  status: active
---

# 消息队列选型论证

## 适用范围
- 用户在多系统间犹豫（Kafka/Pulsar/NATS/RabbitMQ/Redis Stream/MQTT），需要带论证的推荐
- 用户提供场景与约束，需要收敛候选并给出关键权衡

## 决策流程
1. **提取硬约束**（缺任何一项先反问，禁止直接给结论）：
   - 峰值吞吐与消息大小；延迟目标（P99）
   - 持久化需求（at-most-once 可接受 vs 必须持久）
   - 顺序保证 / 事务需求 / 多租户 / 地理复制
   - 运维成本上限（人力与基础设施）
2. **逐层收敛**（按 references/decision-tree.md）：
   - 先分持久化与非持久化两支，再按吞吐/延迟定位，候选 ≤ 2 个。
3. **矩阵核对**（按 references/selection-matrix.md）：
   - 场景速查、性能速查、功能速查三张表逐条核对候选。
4. **输出**：推荐方案 + 备选方案 + 关键权衡 + 置信标注 + 验证建议。
   - 验证建议统一指向 `mq-test-deploy-cases` 技能（冒烟验证）。

## 输出格式
```text
结论: <系统>（一句话理由，带【论证】/【估算】标注）
备选: <系统>（何时反超推荐方案）
关键权衡: 1-3 条
基线建议: 关键配置基线（如 Kafka: RF=3, min.insync.replicas=2）
验证: 建议执行 mq-test-deploy-cases 的 TC-DEP-01/05
```

## 红线
- 约束不足时必须先反问（参见用例 U1 回放示例）。
- 禁止无来源给定量性能数字；引用 references 中带【估算】的数字时原样保留标注。
- 涉及版本能力（如 Kafka 4.x KIP-932 队列语义）必须核对时效，超期则提示用户核实官方文档。

## 参考
- references/decision-tree.md（决策树与一句话选型）
- references/selection-matrix.md（场景/性能/功能速查矩阵）
