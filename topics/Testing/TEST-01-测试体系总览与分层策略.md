# T.01 测试体系总览与分层策略

> **本文档定位**：项目测试验证体系的顶层设计与导航。用例细节分见 TEST-02（部署）/TEST-03（集成）/TEST-04（集群）；失败处置流程见 TEST-05；自动化自检见 TEST-06。

## 目录

- [T.01 测试体系总览与分层策略](#t01-测试体系总览与分层策略)
  - [目录](#目录)
  - [T.01.1 与 02-43/03-59 的分工](#t011-与-02-4303-59-的分工)
  - [T.01.2 五层测试金字塔](#t012-五层测试金字塔)
  - [T.01.3 覆盖矩阵：场景 × 系统](#t013-覆盖矩阵场景--系统)
  - [T.01.4 权威基准锚点（引用而非自造）](#t014-权威基准锚点引用而非自造)
  - [T.01.5 质量门禁](#t015-质量门禁)
  - [T.01.6 与 04 系列动力学的衔接](#t016-与-04-系列动力学的衔接)
  - [T.01.7 参考来源](#t017-参考来源)

---

## T.01.1 与 02-43/03-59 的分工

项目已有测试相关内容，本目录不重复：

| 文档 | 层级 | 回答的问题 | 本目录的关系 |
| ------ | ------ | ----------- | -------------- |
| 02-43 消息测试设计（02 系列） | 设计论证 | 为什么测、测哪些维度 | 本目录用例是其"可靠性/性能"维度的可执行化 |
| 03-59 消息测试实践指南（03 系列） | 操作指南 | 测试策略、环境搭建、通用方法 | 本目录复用其参数（如 stress.messages.count=1000000）并落到具体命令 |
| TEST-01~06（本目录） | 用例库 + 机制 | 具体执行什么命令、预期什么输出、失败怎么纠正、如何自动验证 | 与 02-43/03-59 互链互补 |

## T.01.2 五层测试金字塔

| 层 | 名称 | 目标 | 主要工具 | 项目资产 | 频率 |
| ---- | ------ | ------ | ---------- | ---------- | ------ |
| L1 | 单元/组件 | 生产者/消费者/序列化/路由逻辑正确 | JUnit/pytest + Mock；嵌入式服务 | `examples/` 52 个示例 | 每次提交 |
| L2 | 契约与模式 | 消息格式兼容、Schema 演进安全 | Schema Registry 兼容模式检查 | `config-templates/schema-check` 类参数 | 每次提交 |
| L3 | 集成 | 端到端投递语义（不丢/不重/顺序/事务） | Testcontainers + Toxiproxy | TEST-03 用例；docker-compose 模板 | 每日 |
| L4 | 部署与集群验证 | 安装/升级/回滚/故障转移/扩缩容正确 | docker compose + 项目 scripts | TEST-02/04 用例 | 每次发布 + 每周 |
| L5 | 混沌与韧性 | 故障注入下系统行为符合理论预期 | Chaos Mesh / 自定义 nemesis | `scripts/chaos-test.sh`；04-04 混沌工程 | 每月 |

层间原则【论证】：上层失败必须能定位到某下层用例缺失——若 TC-CLU-02（网络分区）失败而 L3 无对应网络故障用例，先在 L3 补用例再排查产品问题（防"用 E2E 当单元测试用"的低成本倒置）。

```bash
# 分层执行入口（均为项目已有或本批次新增脚本）
# L3 集成冒烟（Testcontainers 环境由 TEST-03 用例代码自建）
./topics/scripts/mq-smoke-test.sh kafka        # 单系统冒烟
./topics/scripts/message-test.sh all           # 全量消息功能测试
# L4 集群验证
./topics/scripts/chaos-test.sh                 # 混沌注入（对应 TC-CLU 系列）
./topics/scripts/benchmark-all.sh              # 六系统基准
```

各层的进入/退出标准（层间晋升依据）：

| 层 | 进入标准 | 退出标准（晋升下一层） |
| ---- | ---------- | ------------------------ |
| L1 | 代码可编译、Mock 就绪 | 覆盖率 ≥ 80%，0 失败 |
| L2 | L1 全绿、Schema 已定义 | 兼容矩阵全操作符合预期 |
| L3 | L2 全绿、compose 环境 healthy | E2E 语义用例全过（不丢/不重/顺序/事务） |
| L4 | L3 全绿、稳态基线已记录 | 部署/升级/恢复用例全过，RTO/RPO 有实测值 |
| L5 | L4 全绿、故障预案与回滚脚本就绪 | 稳态恢复达标，韧性缺陷单已开立 |

层间晋升失败的处理：不允许"跳层修复"（如 L3 失败直接改产品配置让 L5 过）——必须回到失败层定位（TEST-05 根因五步法），修复后自该层重新晋升。

## T.01.3 覆盖矩阵：场景 × 系统

纵轴为消息系统，横轴为测试场景；●=本目录已有用例，○=依赖外部基准/后续补充：

| 系统 \ 场景 | 部署 | 升级回滚 | 备份恢复 | E2E 语义 | 网络故障 | 拓扑故障 | 一致性验证 |
| ------------- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Kafka | ● | ● | ● | ● | ● | ● | ○(Jepsen/TLA+) |
| NATS/JetStream | ● | ● | ○ | ● | ● | ● | ○(Jepsen) |
| RabbitMQ | ● | ● | ● | ● | ● | ● | ○ |
| Pulsar | ● | ○ | ○ | ● | ● | ○ | ○ |
| Redis Stream | ● | ○ | ● | ● | ● | ○ | ○ |
| MQTT(Broker) | ● | ○ | ○ | ● | ● | ○ | ○ |
| RocketMQ | ● | ● | ● | ● | ● | ● | ● |
| Redpanda | ● | ● | ● | ● | ● | ● | ●(Jepsen 公开报告锚点) |

矩阵说明：RocketMQ/Redpanda 用例已在 TEST-02/03/04 中补齐（TC-DEP-04c/04d/08c/08d/11b/11c/15b/15c、TC-INT-08b/08c/10b/10c/11d/11e、TC-CLU-06b/06c/07b/07c）。上述用例基于官方 Docker 镜像设计，均标注"未在本项目 CI 实际运行"的诚实口径；Redpanda 一致性列标 ● 是引用其官方 Jepsen 报告作为外部锚点（T.01.4），非本项目自测。

补充覆盖口径：测试类型维度（功能/性能/可靠性）与场景维度正交——同一格 ● 的用例应至少覆盖其中两类（如 Kafka 部署格含 TC-DEP-01 功能验证与 TC-DEP-05 静态校验）。

首次搭建测试体系的执行顺序建议（2 周落地）：

| 天数 | 动作 | 产出 |
| ------ | ------ | ------ |
| D1-2 | 跑通 doc-self-check.sh quick 与 mq-smoke-test.sh（单系统） | 自检基线 |
| D3-5 | 按 TEST-02 批次 A/B 执行部署用例 | 部署测试基线报告 |
| D6-9 | 按 TEST-03 执行 L2/L3 用例（先契约后 E2E） | 集成测试基线报告 |
| D10-12 | 按 TEST-04 执行 TC-CLU-01/02/03 | 集群验证基线 + RTO 实测 |
| D13-14 | 汇总门禁阈值、挂账 WARN、下月计划 | 月度测试报告 |

场景维度的覆盖口径：部署=安装+配置校验；E2E 语义=不丢/不重/顺序/事务四件套；网络故障=延迟/断连/带宽三注入；拓扑故障=杀节点/分区/滚动/扩缩；一致性验证=黑盒队列检验/形式化对照/运行时断言三层（T.04.3）。每格 ● 至少对应 1 条编号用例；同一系统的 ● 用例必须在同一 compose 拓扑上可串行执行（环境复用，避免重复起停）。

## T.01.4 权威基准锚点（引用而非自造）

一致性/正确性验证不重复造轮子，锚定公开权威资产（AGENTS.md §4.2 同款原则）：

| 资产 | 覆盖对象 | 用途 |
| ------ | ---------- | ------ |
| [Jepsen: Redpanda 21.10.1 分析](https://jepsen.io/analyses/redpanda-21.10.1) | Redpanda 事务/compact 语义 | 本项目 Redpanda 结论的引用基准 |
| Jepsen 的 Kafka / NATS JetStream 系列报告（jepsen.io/analyses） | Kafka 与 JetStream 历史版本 | 版本演进中的已知问题对照 |
| [Kafka KRaft TLA+ 规范](https://github.com/apache/kafka/tree/trunk/metadata/src/main/resources/common/metadata)（apache/kafka 仓库） | KRaft 元数据一致性 | 形式化验证锚点 |
| [Testcontainers Kafka/Redpanda 模块](https://testcontainers-python.readthedocs.io/en/testcontainers-v4.3.0/modules/kafka/README.html) | L3 集成测试容器化 | TEST-03 用例基础设施 |
| [Toxiproxy（Shopify）](https://qaskills.sh/blog/toxiproxy-fault-injection-testing-guide-2026) | 确定性网络故障注入 | TEST-03 网络故障用例 |
| [Chaos Mesh](https://chaos-mesh.org) | K8s 环境混沌编排 | TEST-04 编排样例 |

使用时注意时效：Jepsen 报告针对特定历史版本，引用结论必须连同版本号（如"Redpanda 21.10.1 的事务边界问题"），不得泛化为"Redpanda 现在仍有此问题"。

## T.01.5 质量门禁

进入 CI/发布流程的硬性阈值（与 03-59 参数对齐）：

| 门禁 | 阈值 | 失败处置 |
| ------ | ------ | ---------- |
| L1 单元测试 | 核心模块覆盖率 ≥ 80%，执行 < 5 分钟 | 阻断合并 |
| L3 集成测试 | E2E 不丢不重；`test.functional.timeout.seconds=30` 内完成 | 阻断合并，转 TEST-05 分类 |
| L4 部署用例 | TEST-02 全量 PASS；升级用例含回滚验证 | 阻断发布 |
| L4 集群用例 | 故障恢复时间 ≤ `recovery.timeout.seconds=300`；URP=0 | 阻断发布 |
| L5 混沌实验 | 稳态指标在实验后 5 分钟内恢复基线 ±10%【估算】 | 开韧性缺陷单 |
| 文档自检 | `doc-self-check.sh quick` 无 FAIL | 阻断批次收尾（AGENTS.md §7.2.4） |

```bash
# 门禁串接示例（CI pipeline 片段）
./topics/scripts/doc-self-check.sh quick || exit 1
./topics/scripts/mq-smoke-test.sh all   || exit 1
./topics/scripts/benchmark-all.sh       || exit 1
```

门禁阈值的依据与调整规则【论证】：

| 门禁项 | 阈值 | 依据 | 调整规则 |
| -------- | ------ | ------ | ---------- |
| 覆盖率 ≥80% | L1 | 行业常见单元测试基线（03-59 表） | 只升不降；核心模块（序列化/幂等）建议 90% |
| 集成超时 30s | L3 | `test.functional.timeout.seconds`（03-59） | 按最长用例实测 P99 调整并记录 |
| 错误率 <0.1% | L3/L4 | 压测通过线（03-59） | 金融类场景收紧至 0.01%【估算】 |
| 恢复 ≤300s | L4 | `recovery.timeout.seconds`（03-59） | 按 RTO 目标分级（T.04.6 表） |
| 稳态恢复 ±10% | L5 | 04-04 稳态规范的量级化【估算】 | 连续 3 次实验超阈值则修订基线本身 |

阈值调整必须双向同步：改脚本默认值 ↔ 改本文档与 03-59 的参数引用，禁止只改一处（doc-self-check 的 WARN 挂账机制兜底）。

## T.01.6 与 04 系列动力学的衔接

04 系列（动态系统论）给出故障传播的理论模型，本目录负责用实验验证模型假设：

| 04 系列论点 | 本目录验证用例 | 验证方式 |
| ------------- | ---------------- | ---------- |
| 04-03 故障传播方程（级联失效与放大系数） | TC-CLU-05 级联故障注入 | 对比注入单点 vs 级联的指标劣化曲线 |
| 04-04 混沌工程稳态假设 | TC-CLU-06 混沌编排 | 稳态指标定义与回滚验证复用 04-04 的稳态规范 |
| 04-01 反馈回路（背压/重试放大） | TC-INT-05 重试风暴 | Toxiproxy 注入下游延迟，观测重试放大系数是否接近 α≈0.3【估算】的量级 |

衔接规则【论证】：理论值与实测偏差 > 2 倍时，优先怀疑实验设计（环境噪声、样本不足），其次才修正理论参数；修正须回写 04 系列并标【估算】。

测试度量指标的统一定义（各用例报告必须使用该口径，保证横向可比）：

| 指标 | 定义 | 采集方式 |
| ------ | ------ | ---------- |
| 吞吐（msg/s） | 单位时间成功投递的消息数 | 客户端计数 / broker JMX |
| P99 延迟 | 端到端耗时的 99 分位 | 客户端时间戳差 |
| 恢复时间 | 故障注入→稳态恢复（T.01.5 口径）的时长 | 注入脚本时间戳 vs 监控收敛 |
| 重试放大系数 | 实际发送次数 / 业务请求次数 | producer 指标 |
| 不可用窗口 | 客户端可见错误持续时长 | 测试客户端断言日志 |

批次测试报告模板（每批次测试执行后产出，附于批次说明）：

```text
# 批次测试报告（YYYY-MM-DD）
范围: TC-DEP-xx.. / TC-INT-xx.. / TC-CLU-xx..
环境: <compose 拓扑/版本>
结果: PASS n / FAIL n / SKIP n（SKIP 原因清单）
实测亮点: <如 RTO 实测 23s，优于 60s 目标>
失败建档: <按 TEST-05 分类的用例清单>
挂账: <WARN 项与清偿计划>
```

## T.01.7 参考来源

- [Jepsen Redpanda 分析](https://jepsen.io/analyses/redpanda-21.10.1)、[jepsen-io/redpanda 仓库](https://github.com/jepsen-io/redpanda)
- [Kafka KRaft TLA+ 规范目录](https://github.com/apache/kafka/tree/trunk/metadata/src/main/resources/common/metadata)
- [Testcontainers Kafka 模块文档](https://testcontainers-python.readthedocs.io/en/testcontainers-v4.3.0/modules/kafka/README.html)
- [Toxiproxy 故障注入指南（QASkills）](https://qaskills.sh/blog/toxiproxy-fault-injection-testing-guide-2026)
- 项目内：[02-43 消息测试设计](../02-场景驱动架构设计/02-43-消息测试设计.md)、[03-59 消息测试实践指南](../03-架构与运维实践/03-59-消息测试实践指南.md)、[04-04 混沌工程与系统韧性](../04-动态系统论与演化分析/04-04-混沌工程与系统韧性.md)、[AGENTS.md](../../AGENTS.md) §4.2、[TEST-02](TEST-02-运维部署测试用例.md)、[TEST-03](TEST-03-集成测试用例.md)、[TEST-04](TEST-04-集群测试验证.md)

---

**最后更新**: 2026-11-18
