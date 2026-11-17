---
name: mq-pattern-dlq
description: >
  死信队列（DLQ）设计论证：六系统死信机制（DLX/TTL/重试上限/重投策略）对比，
  按消息价值等级与业务约束给出 DLQ 方案选型建议。Use when 死信队列、DLQ、
  dead letter、重试上限、retry exhaustion、毒消息、poison message、
  消息堆积处理、重试次数设计、死信监控、消息存储、备份恢复、可观测性。
license: Apache-2.0
metadata:
  source-doc: |
    topics/02-场景驱动架构设计/02-17-死信队列设计.md
    topics/03-架构与运维实践/03-44-消息存储与备份恢复指南.md
  derived-at: "2026-11-18"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-18"
  status: active
---

# 死信队列设计论证

## 适用范围
- 需要为业务设计 DLQ 方案（选系统内建机制 vs 自建重试 topic 体系）
- 需要论证重试上限、TTL、重投策略的取值依据

## 决策输入（不足则反问）
1. **消息价值等级**：丢弃可接受 / 可延迟重投 / 不可丢（决定兜底层级）
2. **重试策略**：重试次数上限、退避方式、是否需要人工介入通道
3. **运维成本上限**：能否维护独立的重试 topic 体系与重投工具

## 论证路径
1. 查 references/dlq-comparison.md 取得六系统机制对比：
   - Kafka：无内建 DLX → 重试 topics 分层 + 死信 topic + 人工/连接器转移
   - NATS JetStream：`MaxDeliver` 超限进 AckWait 重投链，死信需配合 advisories
   - RabbitMQ：内建 DLX（`x-dead-letter-exchange`）+ TTL/拒绝/超限触发
   - Pulsar：retry topic + dead letter topic（内建，重试策略可配）
   - Redis Stream：无内建 → PEL 超时转移 + 人工
   - MQTT：broker 相关（部分 broker 支持，协议无内建 DLQ 语义）
2. 按"消息价值等级 × 系统现状"收敛方案组合：
   - 高价值消息：内建死信（RabbitMQ DLX / Pulsar DL topic）+ 死信监控告警 + 人工重投台
   - Kafka 生态：三层 topic（`<biz>` → `<biz>.retry.N` → `<biz>.dlq`）+ 重投脚本
3. 输出结论必须包含：机制选型 + 重试上限取值理由 + 监控项 + 落地入口（互链 `mq-ops-dlq`）。

## 输出格式
```text
结论: <系统机制>（一句话理由【论证】）
重试上限: <N 次>（理由：下游故障恢复时间 vs 消息时效）
监控: 死信深度告警阈值 + 处理时效
落地: 由 mq-ops-dlq 技能执行声明/重投/清理
```

## 红线
- 禁止给"重试次数越多越好"式无依据建议；上限取值必须结合消息时效与下游恢复时间论证。
- 六系统对比以 references 为准，禁止凭印象补写机制细节。
- 代码级实现不在本技能范围（见 topics/examples/ 各语言示例）。

## 参考
- references/dlq-comparison.md（六系统机制对比切片）
- 互链技能：mq-ops-dlq（落地操作）
