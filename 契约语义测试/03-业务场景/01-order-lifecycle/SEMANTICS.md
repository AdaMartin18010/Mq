# 01-order-lifecycle 语义标注

| 维度 | 为什么需要 | 涉及消息 | 验收关注点（GWT 一句话） |
| ---- | ---- | ---- | ---- |
| 交付语义 | 订单不可丢、可重 | OrderCreateCmd | 重试同一 idempotencyKey 仅建一单（ASE-001 族） |
| 顺序性 | 状态机依赖事件序 | 全部事件 | 同 orderId 事件按 occurredAt 单调（ASE-003 族） |
| 幂等去重 | 网络重试/重放 | OrderCreateCmd | broker+应用双层去重（ASE-004/005 族） |
| 死信 | 异常订单隔离处理 | 消费失败事件 | 进入 orders.dlq 且可人工重放（ASE-007/008 族） |
| 事务 | 建单+扣库存原子性 | OrderCreateCmd→库存命令 | 事务边界内两写同生共死（ASE-009 族） |

**设计陷阱**：

1. 状态机断言放消费者侧（事件溯源回放），broker 不保证跨分区全局序——跨 orderId 乱序是合法行为。
2. 幂等键必须随消息头传播到所有下游（trace-id + idempotency-key 双头），仅 payload 幂等可被序列化绕过。

互链：[TEST-12 电商场景](../../Testing/02-集成用例/TEST-12-企业应用场景端到端用例库.md)、[02-57 任务/命令契约](../../topics/02-场景驱动架构设计/02-57-IT通用场景事件契约模式库.md)、fixtures/test-data-orders.json

**最后更新**: 2026-11-18
