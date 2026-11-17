# 07-audit-trail 语义标注

| 维度 | 为什么需要 | 涉及消息 | 验收关注点 |
| ---- | ---- | ---- | ---- |
| 持久化 | 审计=合规资产 | AuditRecordEvent | retention 达保留期、重启/卸载后链完整（ASE-014 族） |
| 顺序性 | prevHash 链的物理基础 | AuditRecordEvent | 全链回放 O(n) 哈希验证通过 |
| 交付语义 | 审计不可丢 | AuditRecordEvent | acks/持久化策略最高级；丢失=审计事故 |

**设计陷阱**：

1. **关闭 broker 去重**（deduplication: false）——审计场景重复消息是取证疑点，去重会销毁证据（与 06-cdc-sync 的去重诉求正相反，体现语义维度的场景相关性）。
2. prevHash 链验证放在独立只读消费者（回放校验器），与业务消费解耦。

互链：[02-57 审计契约模式](../../../../topics/02-场景驱动架构设计/02-57-IT通用场景事件契约模式库.md)、02-payment-reconciliation（evidenceHash 衔接）、[02-50 合规设计](../../../../topics/02-场景驱动架构设计/02-50-消息数据合规设计.md)

**最后更新**: 2026-11-18
