# MQTT 5.0 特性事实切片（派生自 01-16，派生日 2026-11-17）

> **时效声明**: 协议事实基于 OASIS MQTT 5.0 规范（2019 发布），核实至 2026-01；broker 实现差异需查各官方文档。

## 核心特性（5.0 vs 3.1.1）

| 特性 | 语义 | 典型用途 |
|------|------|----------|
| Reason Code | 细粒度 ACK/错误码（CONNACK/PUBACK/SUBACK 等） | 可诊断的错误处理 |
| User Properties | 自定义键值对元数据 | trace-id、业务元数据、路由标签 |
| Shared Subscription | `$share/{group}/{filter}` 组内负载均衡 | 消费者水平扩展 |
| Message Expiry | 消息级过期时间（秒） | 削峰时的时效丢弃 |
| Topic Alias | 主题别名映射（小整数代替长主题） | 降低窄带网络开销 |
| Request/Response | Response Topic + Correlation Data | 设备 RPC |
| Session Expiry | 会话级过期（ disconnect 后保留） | 离线消息与恢复 |

## QoS 语义【定理：OASIS 规范】

- QoS 0：至多一次（fire-and-forget）
- QoS 1：至少一次（PUBACK 确认，可能重复）
- QoS 2：恰好一次（PUBREC/PUBREL/PUBCOMP 四步握手）
- 升级 QoS 提升可靠性但增加延迟与状态开销；订阅端 QoS 取发布/订阅二者较小值【论证】。

## 常见问答口径

- "MQTT 能保证顺序吗" → 协议对同一 topic 的 QoS1/2 消息保持顺序【论证：规范规则】；跨 topic 无序。
- "共享订阅怎么扩缩消费者" → 组内成员动态增减自动重平衡；消息在成员间分发（非广播）。
- "5.0 会话过期与 3.1.1 clean session 的关系" → Session Expiry Interval 取代 clean session，粒度更细（秒级 + 0=瞬时会话）。

---
**同步规则**: 源文档更新后须重新派生并更新 derived-at / last-verified。
