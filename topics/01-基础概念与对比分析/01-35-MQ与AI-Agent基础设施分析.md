# 1.35 MQ 与 AI Agent 基础设施分析

> **时效声明**: 本文事实基于 A2A/MCP 官方发布与 2026 年公开报道核实至 2026-11。Agent 生态演进极快，引用前请复核官方来源。

## 目录

- [1.35 MQ 与 AI Agent 基础设施分析](#135-mq-与-ai-agent-基础设施分析)
  - [目录](#目录)
  - [1.35.1 为什么 Agent 需要消息层](#1351-为什么-agent-需要消息层)
  - [1.35.2 双层协议栈：A2A 与 MCP 的分工](#1352-双层协议栈a2a-与-mcp-的分工)
  - [1.35.3 Agent 消息的核心模式](#1353-agent-消息的核心模式)
    - [A2A Task 生命周期与 MQ 语义映射](#a2a-task-生命周期与-mq-语义映射)
    - [代码骨架（任务入队 + 幂等消费）](#代码骨架任务入队--幂等消费)
    - [A2A Task 生命周期与 MQ 语义映射](#a2a-task-生命周期与-mq-语义映射-1)
    - [Agent 流量可观测性（比人类流量更严苛）](#agent-流量可观测性比人类流量更严苛)
    - [落地成熟度路线图](#落地成熟度路线图)
  - [1.35.4 六系统承载 Agent 工作负载的适配度](#1354-六系统承载-agent-工作负载的适配度)
    - [逐系统落地要点](#逐系统落地要点)
    - [Agent 编排参考拓扑（NATS + Kafka 双栈示例）](#agent-编排参考拓扑nats--kafka-双栈示例)
    - [Agent 任务消息信封规范（跨系统通用设计）](#agent-任务消息信封规范跨系统通用设计)
    - [Agent 消息安全清单](#agent-消息安全清单)
    - [常见问答（FAQ）](#常见问答faq)
    - [Agent 管道度量指标（接入 1.33 监测）](#agent-管道度量指标接入-133-监测)
    - [与项目体系的最终接口](#与项目体系的最终接口)
  - [1.35.5 选型建议与架构模式](#1355-选型建议与架构模式)
  - [1.35.6 参考来源](#1356-参考来源)
    - [术语速查](#术语速查)
    - [变更记录](#变更记录)

---

## 1.35.1 为什么 Agent 需要消息层

AI Agent 从"单轮问答"走向"多 Agent 协作"后，产生了与人类调用 API 完全不同的通信需求【论证】：

| 需求 | 人类 API 调用 | Agent 工作负载 |
| ------ | --------------- | ---------------- |
| 调用时长 | 毫秒-秒级 | 任务级：秒-小时（长任务异步化） |
| 协商过程 | 无 | 多轮能力协商/委托 |
| 负载形态 | 请求-响应 1:1 | 扇出编排、竞争消费、结果聚合 |
| 背压 | 客户端超时 | 任务队列+优先级+取消语义 |

同步 HTTP 无法承载长任务与编排——**消息层成为 Agent 基础设施的默认选择**【论证：acemq 2026-10 对比分析：RabbitMQ vs Kafka vs NATS for AI agents 在 task hand-off、request-reply、路由、回放、背压五维度的对比】。

## 1.35.2 双层协议栈：A2A 与 MCP 的分工

2026 年形成的事实分工【论证：[博客园 2026-04 综述（引 Atlan 数据）](https://www.cnblogs.com/shanyou/p/20903593)、[Atlan A2A 解析](https://atlan.com/know/google-a2a-protocol/)】：

| 层 | 协议 | 解决的问题 | 核心抽象 |
| ---- | ------ | ----------- | ---------- |
| 垂直层 | **MCP**（Anthropic，2024-11；2025-12 捐赠 Linux 基金会） | Agent ↔ 工具/数据连接 | Tools/Resources/Prompts |
| 水平层 | **A2A**（Google，2025-04 发布） | Agent ↔ Agent 发现/委托/协调 | Agent Cards、Task 生命周期、Artifacts |

生态规模【论证：截至 2026-04：A2A 获 150+ 组织支持（Google/Microsoft/AWS/Salesforce/SAP/ServiceNow），GitHub 22,000+ stars，SDK 覆盖 Python/JavaScript/Java/Go/.NET 五语言】。两者互补而非竞争；MQ 位于两者之下，提供 A2A 任务流转的传输底座【论证】。

## 1.35.3 Agent 消息的核心模式

```text
① 任务入队:   Client → [task-queue] → Agent Pool（竞争消费 = 自然负载均衡）
② 委托协商:   Agent A → [capability topic] → Agent B（A2A Task 语义承载）
③ 状态心跳:   Agent → [heartbeat stream] → Orchestrator（deadletter = 卡死任务）
④ 结果聚合:   Workers → [result topic] → Aggregator（fan-in，按 task-id 路由）
⑤ 人工接入:   Escalation → [human-inbox]（Agent 置信度低时转入人工队列）
```

模式要点【论证】：①任务队列模式天然对应 02-12~46 的现有模式族，**Agent 场景没有发明新模式，但把"重试/死信/幂等"从可选变为必选**（Agent 调用计费且非幂等）；②取消语义是新增量——任务取消需传播到消费端（MQTT 5 取消/ Kafka 中止事务的借鉴）【论证】。

### A2A Task 生命周期与 MQ 语义映射

A2A 的 Task 状态机（submitted→working→input-required→completed/failed/canceled）与 MQ 的映射是工程落地关键【论证：A2A 规范语义】：

| A2A Task 状态 | MQ 承载方式 | 语义注意 |
| --------------- | ------------- | ---------- |
| submitted | task topic 新消息（task-id 为 key） | key 路由保证同任务有序（02-27） |
| working | heartbeat topic 周期心跳 | 心跳缺失 = 卡死检测信号（03-63 自愈联动） |
| input-required | 状态变更事件 | 编排器消费后转人工/转交 |
| artifacts | 结果 topic（大对象引用传址） | 大产出放对象存储，消息传指针 |
| canceled/failed | 终止事件 + DLQ | 取消需消费者协作中断（协作式取消） |

### 代码骨架（任务入队 + 幂等消费）

```python
# 生产者：任务入队（幂等键 = task-id，Agent 重试不重复计费）
producer.send("agent.tasks", key=task_id,
              value={"task_id": task_id, "capability": "code-review",
                     "payload_ref": "s3://...", "budget": 0.05},
              headers=[("idempotency-key", task_id)])
# 消费者：协作式取消 + 幂等执行
while not cancelled(task_id) and not exceeded(budget):
    step = do_step()
    if dup_check(task_id, step):   # 02-14 去重——Agent 重试会真实发生
        continue
    heartbeat(task_id)
```

安全红线【论证】：**消息即 prompt 注入面**——Agent 消费的"任务消息"必须做来源鉴权与内容过滤（不可信消息诱导 Agent 执行危险工具调用）；任务消息带预算/权限声明，消费者侧强制校验（不可信声明不可放大权限）。

### A2A Task 生命周期与 MQ 语义映射

A2A 的 Task 状态机（submitted→working→input-required→completed/failed/canceled）与 MQ 的映射是工程落地关键【论证：A2A 规范语义】：

| A2A Task 状态 | MQ 承载方式 | 语义注意 |
| --------------- | ------------- | ---------- |
| submitted | task topic 新消息（task-id 为 key） | key 路由保证同任务有序（02-27） |
| working | heartbeat topic 周期心跳 | 心跳缺失 = 卡死检测信号（03-63 自愈联动） |
| input-required | 状态变更事件 | 编排器消费后转人工/转交 |
| artifacts | 结果 topic（大对象引用传址） | 大产出放对象存储，消息传指针 |
| canceled/failed | 终止事件 + DLQ | 取消需消费者协作中断（协作式取消） |

```python
# 任务入队（幂等键 = task-id，Agent 重试不重复计费）
producer.send("agent.tasks", key=task_id,
              value={"task_id": task_id, "capability": "code-review",
                     "payload_ref": "s3://...", "budget": 0.05},
              headers=[("idempotency-key", task_id)])
# 消费者：协作式取消 + 幂等执行
while not cancelled(task_id) and not exceeded(budget):
    step = do_step()
    if dup_check(task_id, step): continue   # 02-14 去重——Agent 重试真实发生
    heartbeat(task_id)
```

### Agent 流量可观测性（比人类流量更严苛）

调试单元是"决策链"而非单次调用【论证】：task-id 贯穿 header（02-23）+ OTel span；每任务回写 budget 消耗（03-65 成本归集）；DLQ 即 Agent 失败复盘台（02-17 升级版）；轨迹 topic 全量留痕支持决策回放（Kafka 回放能力）。

### 落地成熟度路线图

| 阶段 | 标志 | 验收 |
| ------ | ------ | ------ |
| 1 任务队列化 | 单 Agent 任务入队/竞争消费 | 幂等键+DLQ 就绪 |
| 2 编排化 | 多 Agent 委托/聚合（A2A 语义） | 状态机映射表评审通过 |
| 3 可观测 | 决策链 trace + 成本计量上线 | TEST-07 扩展用例通过 |
| 4 自治辅助 | 失败任务自动分类/重派（人工确认） | 02-49 L2 自愈 + 护栏评审 |

## 1.35.4 六系统承载 Agent 工作负载的适配度

| 维度 | Kafka | RabbitMQ | NATS | Pulsar | Redis | MQTT |
| ------ | :---: | :---: | :---: | :---: | :---: | :---: |
| 任务队列/竞争消费 | ⚠️ 组内分区约束 | ✅ 经典强项 | ✅ queue group | ✅ Shared sub | ✅ 轻量 | ⚠️ broker 相关 |
| Request-Reply | ⚠️ 需应用模式 | ✅ RPC 成熟 | ✅ 原生 | ✅ | ⚠️ | ✅ MQTT 5 req/res |
| 长任务回放/审计 | ✅ 最强 | ⚠️ | ⚠️ JetStream 窗口 | ✅ | ❌ | ❌ |
| 低延迟编排 | ⚠️ | ✅ | ✅ 最优 | ⚠️ | ✅ | ✅ |
| 取消/优先级 | ⚠️ | ✅ TTL/优先级队列 | ✅ TTL/优先级 | ✅ 延迟消息 | ⚠️ | ⚠️ |

✅=原生适配；⚠️=需工程补齐（口径源自 acemq 对比与本项目 01 系列机制分析的交叉推断【论证】）。

### 逐系统落地要点

**Kafka**：Agent 轨迹与事件流的默认底座。任务队列语义需自建（task topic + 消费组）；长任务回放与审计是独有优势；延迟非强项——编排层慎用 req-reply 模式（用异步任务状态代替）【论证】。

**RabbitMQ**：经典任务队列+RPC 双强项，Agent 编排原型最快；吞吐天花板较低，高并发 Agent 集群（千级 worker）需分片集群；TTL/优先级/死信原生——Agent 任务取消与超时开箱即用【论证】。

**NATS**：低延迟编排首选；Core req-reply 原生 + queue group 竞争消费 = Agent 模式的"最小完备集"；JetStream 补持久化但回放窗口有限——轨迹全量留痕不建议放 JetStream【论证】。

**Pulsar**：Shared/Key_Shared 订阅与 Agent 任务分发语义贴合；分层存储承载轨迹长留存；运维重于前两者，平台团队成熟时用【论证】。

**Redis Stream**：轻量任务队列（PEL + 消费组），原型与中小规模成本最优；无回放与审计能力，失败任务复盘靠应用侧日志【论证】。

**MQTT**：设备型 Agent（边缘/IoT）；MQTT 5 的 req/res + 共享订阅对齐 Agent 模式；broker 间能力差异大，多租户 Agent 场景先核实 broker 配额语义【论证】。

### Agent 编排参考拓扑（NATS + Kafka 双栈示例）

```text
控制面（低延迟编排）：Client → NATS req-reply → Orchestrator → task 下发（NATS queue group）
数据面（轨迹/审计）：Worker → agent.traces topic（Kafka）→ 回放/训练/复盘
衔接：Orchestrator 将 task-id 同时写入 NATS 任务消息与 Kafka 轨迹消息（trace-id 贯穿）
```

该拓扑复用 02-08 混合架构原则：控制面求快、数据面求全，两栈各司其职【论证】。

### Agent 任务消息信封规范（跨系统通用设计）

```json
{
  "envelope_version": "1.0",
  "task": {
    "id": "task-uuid（幂等键/追踪键）",
    "type": "capability 名（对应 A2A skill/agent card）",
    "priority": 1,
    "budget": {"tokens": 50000, "usd": 0.10, "deadline": "ISO8601"}
  },
  "payload_ref": "对象存储指针（大对象不传内联）",
  "callback": {"reply_to": "agent.results", "correlation": "task-uuid"},
  "security": {"signed_by": "编排器身份", "allowed_tools": ["read", "grep"]}
}
```

信封设计规则【论证】：① budget 与 allowed_tools 由编排器签名下发，消费者强制校验（不可信消息不可放大权限）；② 大对象一律引用传址（消息 KB 级，对象存储 MB 级）；③ envelope_version 支持信封演进（02-35 版本兼容）；④ correlation = task-id，打通结果聚合与追踪。

### Agent 消息安全清单

- [ ] 任务消息签名/来源鉴权（防伪造任务注入）
- [ ] payload 内容过滤（防 prompt injection 经消息进 Agent）
- [ ] 消费者工具白名单校验（信封 security.allowed_tools 与实际调用比对）
- [ ] 结果消息同样鉴权（防伪造结果污染聚合器）
- [ ] 轨迹 topic 访问控制（决策链可能含敏感推理过程）

### 常见问答（FAQ）

| 问题 | 回答口径 |
| ------ | ---------- |
| "现有 MQ 要换吗" | 多数情况不用——Agent 负载落在 02 系列既有模式内；按 1.35.4 适配度补工程即可 |
| "A2A 会取代 MQ 吗" | 不会——A2A 是语义层协议，MQ 是传输层；A2A Task 恰需 MQ 承载长任务异步化【论证】 |
| "Agent 消息要单独建集群吗" | 原型共享；生产建议逻辑隔离（独立 topic 前缀+配额），物理隔离按安全等级定【估算】 |
| "死信里的 Agent 任务能自动重派吗" | 只自动分类，重派必须人工确认——失败原因未明时重派会重复烧钱（02-49 红线） |
| "先上 A2A 还是先上 MQ" | 先 MQ（任务队列化是底座），A2A 语义层后加（成熟路线图阶段 1→2） |

### Agent 管道度量指标（接入 1.33 监测）

| 指标 | 定义 | 告警起点【估算】 |
| ------ | ------ | ------------------ |
| 任务吞吐 | 完成任务数/分 | 突降 50% |
| 任务时延 | 入队→完成 P95 | 超 budget deadline 比例 >5% |
| 成本效率 | 美元/成功任务 | 环比上升 >30% |
| 失败分类率 | DLQ 任务自动分类占比 | 治理目标 ≥80% |
| 心跳存活 | 无心跳工作进程数 | >0 即查（卡死检测） |

### 与项目体系的最终接口

- 模式层：Agent 模式全部映射 02-12~46 既有模式族（无新模式，只有必选强度变化）【论证】
- 选型层：1.35.4 适配度矩阵并入 01-19 选型决策矩阵的"AI 负载"行
- 测试层：TEST-07 模式可扩展 Agent 任务用例（幂等/取消/DLQ 分类）
- 观测层：上述度量指标并入 1.33 指标矩阵的"业务语义指标"行
- 治理层：消息注入面安全清单并入 03-16 安全加固检查清单

## 1.35.5 选型建议与架构模式

| Agent 场景 | 推荐底座 | 理由 |
| ------------ | ---------- | ------ |
| 编排型多 Agent（任务分解/聚合） | RabbitMQ / NATS | req-reply + 竞争消费 + 低延迟 |
| 高吞吐 Agent 事件流（遥测/轨迹） | Kafka / Pulsar | 回放与审计是 Agent 调试的生命线 |
| 边缘/设备 Agent | MQTT（5.0 req/res + 共享订阅） | 协议原生对齐 |
| 轻量任务队列（原型期） | Redis Stream | 运维成本最低，接受无回放 |
| 混合（本项目推荐参考） | NATS Core（编排）+ Kafka（轨迹）双栈 | 对齐 02-08 混合架构模式 |

架构红线【论证】：Agent 任务的**幂等与去重必须显式设计**（Agent 重试会真实花钱）；死信队列升级为"失败任务复盘台"（Agent 失败样本是高价值训练数据）；消息追踪（02-23）升级为全链路边Span（Agent 决策链观测）。

## 1.35.6 参考来源

- [Atlan：Google A2A 协议解析](https://atlan.com/know/google-a2a-protocol/)、[A2A 生态 2026-04（150+ 组织）](https://www.cnblogs.com/shanyou/p/20903593)
- [acemq：RabbitMQ vs Kafka vs NATS for AI Agents（2026-10）](https://acemq.com/compare/message-brokers-for-ai-agents/)
- 项目内：[AI_SKILL-01 Agent Skills 标准](../AI_Skill/AI_SKILL-01-国际Agent-Skills标准与生态对齐.md)、[02-08 混合架构案例](../02-场景驱动架构设计/02-08-混合架构案例.md)、[02-12 消息路由策略](../02-场景驱动架构设计/02-12-消息路由策略.md)
- [A2A 官方仓库](https://github.com/a2aproject/A2A)、[MCP 官方文档](https://modelcontextprotocol.io/)

> 边界声明：本文聚焦"MQ 作为 Agent 基础设施"的选型与模式；Agent 框架本身（LangGraph/CrewAI 等）与 A2A SDK 用法不在范围。生态数据（组织数/stars）为 2026-11 转引的公开报道口径，引用前复核。

### 术语速查

| 术语 | 含义 |
| ------ | ------ |
| Agent Card | A2A 的能力声明文件（发现/委托入口） |
| Task | A2A 的任务单元（本文映射为 MQ 消息） |
| Artifact | Agent 产出的结果对象（大对象引用传址） |
| 协作式取消 | 消费者响应取消信号优雅中断（非强杀） |
| 决策链 | Agent 完成任务的全步骤轨迹（调试/审计单元） |

### 变更记录

2026-11-17 批次22 新建：A2A/MCP 生态核实至 2026-11（150+ 组织、五语言 SDK 口径转引自公开报道）。

- [OpenAI Agents 实践指南](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf)

---

**最后更新**: 2026-11-17
