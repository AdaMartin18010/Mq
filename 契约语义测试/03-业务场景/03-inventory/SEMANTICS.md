# 03-inventory 语义标注

| 维度 | 为什么需要 | 涉及消息 | 验收关注点 |
| ---- | ---- | ---- | ---- |
| 事务 | 扣减+订单状态原子 | ReserveStockCmd/ConfirmDeductionCmd | 两写同生共死；失败即释放（ASE-009 族） |
| 幂等去重 | 重复确认=超库存 | ConfirmDeductionCmd | 同 reservationId 二次确认被拒绝 |
| 顺序性 | 预留→过期→确认的乱序防御 | 全部 | 过期后到达的确认必须判非法（状态机断言） |
| 背压 | 大促洪峰 | StockReservedEvent | 消费 lag 平台期 + 降级预案触发（ASE-010/011 族） |
| TTL过期 | 预留不过期=库存锁死 | ReserveStockCmd.ttlSeconds | 到期自动释放事件必达 |

**设计陷阱**：

1. TTL 释放用**延迟消息或定时扫描**实现（矩阵 ○/◐ 格），契约只声明 ttlSeconds 语义不绑定实现。
2. 大促场景的背压验收含降级路径：lag 超阈时拒绝新预留（fail-fast）而非无限排队。

互链：[02-12 削峰填谷设计](../../topics/02-场景驱动架构设计/02-12-消息削峰填谷设计.md)、01-order-lifecycle 场景（事务对端）

**最后更新**: 2026-11-18
