# T.14 skill 触发回放测试（Testing 体系）

> **置信口径**: 用例设计=【论证】；技能事实以 AI_Skills/ 各 SKILL.md 声明为准。
> **时效声明**: 核实至 2026-11-18（7 技能结构回放基准日）。
> **本文档定位**: 批次 70 落地文档。为 AI_Skills/skills/ 7 个技能定义触发回放用例（每技能 3 条：正例/边界/反例），注册于 test-registry.tsv（域 SKL）。执行方式：人工或代理按用例重放触发词并核对技能输出要点（--skill-drift 脚本负责结构漂移，本用例负责**行为**漂移）。

## 用例总表（21 条）

| 用例 ID | 技能 | 类型 | 触发词（回放输入） | 期望要点（核对项） |
| ---- | ---- | ---- | ---- | ---- |
| TC-SKL-01 | mq-selection | 正例 | "Kafka 和 Pulsar 怎么选" | 引用 selection-matrix 六维对比；给出决策树入口（01-59） |
| TC-SKL-02 | mq-selection | 边界 | "只有 3 台 4C8G 机器，日志采集选哪个" | 触达资源约束分支；禁止推荐 Pulsar 全量部署【论证】 |
| TC-SKL-03 | mq-selection | 反例 | "推荐一个最好的消息队列" | 拒绝单一答案；返回"按场景"决策框架 |
| TC-SKL-04 | mq-doc-lint | 正例 | "检查这篇文档合规吗"（附正常文档） | 输出三声明/密度/日期核对结论，引用 doc-self-check.sh |
| TC-SKL-05 | mq-doc-lint | 边界 | "检查"（无附件） | 要求提供文件路径或粘贴内容，不臆造结论 |
| TC-SKL-06 | mq-doc-lint | 反例 | "检查文档"（附缺三声明骨架文档） | 逐条列出缺失项（三声明/目录/日期），不通过 |
| TC-SKL-07 | mq-ops-dlq | 正例 | "Kafka 消费失败消息怎么处理" | 走 DLQ 分支：topic 隔离+重放脚本+监控指标（01-65） |
| TC-SKL-08 | mq-ops-dlq | 边界 | "RabbitMQ 死信队列设置" | 给出 DLX 声明步骤（01-65 AMQP 路径）而非 Kafka 方案 |
| TC-SKL-09 | mq-ops-dlq | 反例 | "把积压消息全删了" | 拒绝；给安全清理流程（先消费/转储后清理） |
| TC-SKL-10 | mq-ops-kafka-upgrade | 正例 | "Kafka 3.8 升级到 4.4 的步骤" | preflight-check.sh 调用链 + 版本跳跃规则（KRaft 前置） |
| TC-SKL-11 | mq-ops-kafka-upgrade | 边界 | "直接升级到最新版" | 要求确认当前版本与目标版本；说明跳板版本要求 |
| TC-SKL-12 | mq-ops-kafka-upgrade | 反例 | "生产集群现在升级"（无备份确认） | 拒绝直接执行；强制快照/回滚预案检查项 |
| TC-SKL-13 | mq-pattern-dlq | 正例 | "设计订单支付的超时补偿" | 给出 saga/延迟消息模式对照（02 系）+ DLQ 兜底 |
| TC-SKL-14 | mq-pattern-dlq | 边界 | "通知场景需要 DLQ 吗" | 区分可丢弃/不可丢弃消息，给出判断树 |
| TC-SKL-15 | mq-pattern-dlq | 反例 | "所有失败都重试 100 次" | 拒绝；毒消息收敛原则（01-65 重试放大系数） |
| TC-SKL-16 | mq-mqtt-deep-dive | 正例 | "MQTT QoS2 和 Kafka acks=all 等价吗" | 不等价论证（协议语义 vs 复制确认，01-64/01-63 指针） |
| TC-SKL-17 | mq-mqtt-deep-dive | 边界 | "十万设备上线风暴怎么接" | 引用 shared subscription + 背压章节（01-64/01-66） |
| TC-SKL-18 | mq-mqtt-deep-dive | 反例 | "MQTT 能保证消息不丢" | 纠正：依赖 QoS+会话+持久化的组合条件【定理】 |
| TC-SKL-19 | mq-nats-deep-dive | 正例 | "JetStream 和 Kafka 的区别" | 存算对比 + 轻量运维优势 + 生态差距（references/nats-facts.md） |
| TC-SKL-20 | mq-nats-deep-dive | 边界 | "核心 NATS 能做持久化吗" | 不能；区分 Core/JetStream（references 事实卡） |
| TC-SKL-21 | mq-nats-deep-dive | 反例 | "用 NATS 替换所有 Kafka" | 拒绝一刀切；给出适用域对照（01-26/01-59） |

## 执行与判定

- 执行人：代理（回放）或人工；判定=期望要点逐条核对（P/F）。
- 失败处置：技能行为漂移 → 修订对应 SKILL.md 触发词/要点 → AI_SKILL-06 审计报告追加记录 → 版本号+1。
- 频率：技能内容变更后必跑；例行每季度一次（并入 TEST-06 月度回顾清单）。
- registry：TC-SKL-01~21 已注册（域 SKL，env E0，script mq-skill-replay.sh[占位]，status pending——回放为人工/代理行为，不绑定自动脚本）。

---

**最后更新**: 2026-11-18
