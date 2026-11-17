# 04-notification 语义标注

| 维度 | 为什么需要 | 涉及消息 | 验收关注点 |
| ---- | ---- | ---- | ---- |
| 消息过滤 | 偏好/通道路由 | NotificationRequestedCmd | topic key 路由到正确通道队列（T.14 过滤格 ●） |
| 持久化 | 通知可补投 | 全部 | broker 重启后未投递命令不丢 |
| 重试退避 | 外部通道限流 | NotificationFailedEvent(retryable=true) | 指数退避 + 最大次数 + 最终死信（ASE-006 族） |
| 死信 | 不可重试失败隔离 | NotificationFailedEvent(retryable=false) | 进 DLQ 并告警，不自动再投 |

**设计陷阱**：

1. contentRef 用 claim-check 模式——通知 payload 小而内容大，broker 只传引用（02-19 claim-check 衔接）。
2. 多通道 fan-out 的幂等粒度是 (notifyId, channel) 二元组，不是 notifyId 一元组。

互链：[02-57 Webhook 交付契约](../../../../topics/02-场景驱动架构设计/02-57-IT通用场景事件契约模式库.md)、webhook-delivery-template.yaml、01-65 DLQ 工程解析

**最后更新**: 2026-11-18
