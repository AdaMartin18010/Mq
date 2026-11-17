# AI Agent 消息契约测试（批次 86）

> **置信口径**: A2A/MCP 协议结构=【定理】（以官方规范为准）；测试设计=【论证】。
> **时效声明**: A2A 已入 Linux Foundation Agentic AI 托管（2025 年中核实路径）；MCP 2025-03 起 Streamable HTTP 替代原 SSE 传输——执行时以官方仓库最新 spec 复核。
> **本文档定位**: AI 时代消息契约（A2A/MCP）的测试用例层，衔接 01-35（MQ×AI Agent 知识篇）与 08-task-queue 场景（agent 任务=任务队列特化）。

## 一、协议消息结构要点（测试输入模型）

| 协议 | 载体 | 关键消息结构 | 与本项目 12 维度的接口 |
| ---- | ---- | ---- | ---- |
| A2A | HTTP+JSON（SSE 流式） | Task{id,status,artifacts[]} / Message{role,parts[]}；Agent Card（well-known 发现文档） | 交付语义=任务状态机可达性；顺序性=SSE 事件序；背压=流式窗口 |
| MCP | JSON-RPC 2.0（stdio / Streamable HTTP） | tools/call、resources/read、notifications；长任务=客户端轮询或服务端通知 | 交付语义=通知至少一次（重连续传）；幂等去重=request id |

## 二、测试用例（注册 TC-AIG-01~06）

| 用例 | 对象 | GWT 摘要 |
| ---- | ---- | ---- |
| TC-AIG-01 | A2A 任务生命周期 | GIVEN Agent Card 声明 streaming 能力 WHEN 提交长任务 THEN 状态机 submitted→working→completed 单调，无回退（08-task-queue 状态机断言的 Agent 版） |
| TC-AIG-02 | A2A SSE 背压 | GIVEN 流式产出速率 > 消费速率 WHEN 客户端不读 WHEN 达到服务端缓冲上限 THEN 服务端降速/断开有明确信号（01-66 背压谱系的 HTTP 流式格） |
| TC-AIG-03 | MCP 请求幂等 | GIVEN tools/call 带同 id 重发 WHEN 首次已执行 THEN 服务端返回同结果不重复副作用（幂等去重维度） |
| TC-AIG-04 | MCP 会话恢复 | GIVEN Streamable HTTP 连接中断 WHEN 客户端带 Last-Event-ID 类游标重连 THEN 丢失通知重放且不重复（交付语义=至少一次+幂等组合） |
| TC-AIG-05 | Agent 任务→MQ 桥 | GIVEN A2A Task 映射到 08-task-queue 的 TaskEnvelope WHEN 任务超时 THEN deadline 语义一致（契约等价性断言：两契约 invariants 交集非空） |
| TC-AIG-06 | 消息即工具结果 | GIVEN MCP tool 返回大对象 WHEN 走 claim-check THEN 返回引用与 02-19 模式一致（模式复用验证） |

## 三、与 01-35/01-57 的分工

知识层（A2A/MCP 架构、六系统适配度）见 01-35；本文只定义**可执行断言**。协议版本事实（A2A 版本号、MCP spec 版本）执行批次 WebSearch 官方仓库核实后回填本表。

---

**最后更新**: 2026-11-18
