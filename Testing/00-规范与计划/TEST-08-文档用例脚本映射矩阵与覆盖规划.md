# T.08 文档用例脚本映射矩阵与覆盖规划

> **本文档定位**：项目测试体系的映射层规划——建立 190+ 篇文档、TC 编号用例与 `scripts/*.sh` 之间的系统化映射关系，为本地自动化执行者（hermes）提供“测什么、用什么测、覆盖到哪”的导航。不替代 TEST-01~07 的用例细节，只定义映射规则与覆盖口径。
>
> **置信口径**：脚本名称与存在性为【定理】（可实地 ls 验证）；文档族到用例域的映射为【论证】（基于 TEST-02~07 的用例设计意图与 02/03/04 系列主题关联）；覆盖率为【估算】（按文档族粗粒度统计，非逐篇精确计数）。
>
> **时效声明**：本文映射基于项目 2026-11-18 批次 40-46 完成后的资产清单；scripts/ 目录脚本数以实地 `ls` 为准。

## 目录

- [T.08 文档用例脚本映射矩阵与覆盖规划](#t08-文档用例脚本映射矩阵与覆盖规划)
  - [目录](#目录)
  - [T.08.1 三层资产模型](#t081-三层资产模型)
  - [T.08.2 验证方式分类](#t082-验证方式分类)
  - [T.08.3 文档→验证映射矩阵](#t083-文档验证映射矩阵)
  - [T.08.4 脚本↔用例映射表](#t084-脚本用例映射表)
  - [T.08.5 覆盖统计口径](#t085-覆盖统计口径)
  - [T.08.6 已知缺口与补全计划](#t086-已知缺口与补全计划)
  - [T.08.7 参考来源](#t087-参考来源)

---

## T.08.1 三层资产模型

项目资产按“被验证对象 → 验证设计 → 可执行载体”三层组织：

```text
文档层（被验证对象）        用例层（验证设计）          脚本层（可执行载体）
  01 基础概念与对比分析         TC-DEP / TC-INT /        doc-self-check.sh
  02 场景驱动架构设计           TC-CLU / TC-OBS          mq-smoke-test.sh
  03 架构与运维实践                                      validate-config.sh
  04 动态系统论与演化分析                                chaos-test.sh
  AI_Skill 系列                                         benchmark-all.sh
  Testing 系列                                          message-test.sh
  config-templates/                                     ...
  examples/
```

- **文档层**：知识的权威来源。02/03 系列一一对应（02-23~46 与 03-39~62 成对）；04 系列提供故障传播与稳态理论；AI_Skill 提供技能派生源。
- **用例层**：TC 编号体系（TEST-02/03/04/07）。每例固定“目的 → 步骤 → 预期 → 通过标准 → 失败处置”。
- **脚本层**：`topics/scripts/*.sh` 中的可执行文件。分为 `*-test.sh`（测试用例载体）、`*.sh` 中 `*-check.sh`（运维巡检/静态检查）、以及 `mq-smoke-test.sh`/`doc-self-check.sh` 等跨域入口。

映射方向是单向依赖：用例引用文档的断言，脚本实现用例的步骤；文档不依赖脚本，但脚本缺失会导致用例无法自动化。

## T.08.2 验证方式分类

按验证对象与执行环境分为五类，每类对应不同的文档族与脚本集合：

| 验证方式 | 覆盖文档族 | 用例域 | 代表脚本 | 说明 |
| ---------- | ------------ | -------- | ---------- | ------ |
| 静态验证 | 全部 01~04 系列、Testing、AI_Skill | —（文档级） | `doc-self-check.sh`、`documentation-check.sh`、`knowledge-base-check.sh` | 结构/链接/禁用词/定位声明/密度检查 |
| 契约验证 | 02-12~46 设计模式、03-39~62 操作指南、config-templates/ | TC-INT-01/02、TC-DEP-05~08 | `schema-check.sh`、`validate-config.sh`、`version-compat-check.sh` | Schema、配置模板、版本兼容性 |
| 容器验证 | 02-12~46 消息机制模式、03-39~62 落地操作 | TC-DEP-01~04/04c/04d、TC-INT-03~12、TC-INT-08b/08c/10b/10c/11d/11e | `mq-smoke-test.sh`、`message-test.sh`、`batch-test.sh`、`retry-test.sh`、`idempotency-test.sh`、`transaction-test.sh` | docker-compose/Testcontainers 上的功能验证 |
| 集群验证 | 03-09/03-10 集群/K8s、04-03/04-04 动态系统 | TC-CLU-01~10、TC-CLU-06b/06c/07b/07c | `chaos-test.sh`、`benchmark-all.sh`、`partition-test.sh`、`performance-test.sh` | 拓扑故障、一致性、混沌编排、性能拐点 |
| 可观测验证 | 02-49、03-63、01-33 | TC-OBS-01~12 | `monitor-check.sh`、`alert-quality-check.sh`、`trace-check.sh`、`health-check.sh` | 监测/告警/伸缩/自愈 |

【论证】上述分类与 TEST-01 T.01.2 的五层测试金字塔对齐：静态验证对应 L0/L1 之前的知识库质量；契约验证对应 L2；容器验证对应 L3；集群验证对应 L4/L5；可观测验证跨 L4/L5 的运维面。

## T.08.3 文档→验证映射矩阵

按文档族给出“验证用例域 + 执行脚本 + 覆盖状态”。覆盖状态定义：●=已映射（用例与脚本均存在）、○=部分映射（用例或脚本缺一）、空白=未映射。

| 文档族 | 主要用例域 | 执行脚本 | 覆盖状态 |
| -------- | ------------ | ---------- | :--------: |
| 01-01~01-18 基础概念/选型矩阵 | 静态验证 | `doc-self-check.sh` | ● |
| 01-19~01-24 速查/FAQ | 静态验证 | `doc-self-check.sh` | ● |
| 01-25~01-29 前沿专章（Serverless/AI/多云等） | 静态验证 + 契约验证 | `doc-self-check.sh`、`schema-check.sh` | ○ |
| 02-01~02-11 场景设计总论 | 容器验证、契约验证 | `mq-smoke-test.sh`、`message-test.sh` | ○ |
| 02-12~02-24 消息机制模式（路由/聚合/过滤等） | TC-INT-03~07/09~12 | `message-test.sh`、`filter-test.sh`、`routing-test.sh`、`aggregation-test.sh`、`batch-test.sh` | ● |
| 02-25~02-32 可靠性/幂等/DLQ/事务 | TC-INT-04/07、TC-CLU-05/06 | `idempotency-test.sh`、`retry-test.sh`、`transaction-test.sh`、`chaos-test.sh` | ● |
| 02-33~02-42 桥接/流处理/安全/多活 | TC-INT-02/11、TC-CLU-02 | `bridge-test.sh`、`chaos-test.sh`、`security-check.sh` | ○ |
| 02-43 消息测试设计 | 全部用例域 | `doc-self-check.sh` + 各域脚本 | ● |
| 02-44~02-46 可观测/自治/平台工程 | TC-OBS-01~12 | `monitor-check.sh`、`alert-quality-check.sh`、`health-check.sh` | ● |
| 03-01~03-08 部署/选型/架构模式 | TC-DEP-01~04/04c/04d | `deploy-kafka.sh`、`deploy-nats.sh`、`deploy-rabbitmq.sh`、`mq-smoke-test.sh` | ● |
| 03-09~03-14 集群/K8s/高可用 | TC-CLU-01~05、TC-CLU-07/08 | `chaos-test.sh`、`benchmark-all.sh` | ● |
| 03-15~03-38 运维操作 thick 文档 | TC-DEP-05~15/15b/15c、TC-CLU-03/04 | `validate-config.sh`、`upgrade-check.sh`、`backup-verify.sh` | ○ |
| 03-39~03-62 与 02-23~46 一一对应 | TC-INT/TC-DEP/TC-CLU/TC-OBS 对应子集 | 见 02 系列同编号映射 | ● |
| 04-01~04-05 动态系统论 | TC-CLU-05/06、TC-INT-05、TC-OBS-09/10 | `chaos-test.sh`、`performance-test.sh` | ○ |
| AI_Skill 系列 | 静态验证（--skill-drift） | `doc-self-check.sh --skill-drift` | ○ |
| Testing/ 自身（TEST-01~07） | 静态验证 + 运行自检 | `doc-self-check.sh`、`mq-smoke-test.sh` | ● |
| config-templates/ | 契约验证/静态验证 | `validate-config.sh`、`schema-check.sh` | ● |
| examples/ | 容器验证（多语言回归） | `message-test.sh`（运行层）、各语言编译工具 | ● |

矩阵说明：

- “● 已映射”表示该文档族至少有一个 TC 用例与一个执行脚本与之对应，且用例结构完整（含目的/步骤/预期/通过标准/失败处置）。
- “○ 部分映射”表示存在静态检查或通用脚本，但缺少针对该族全部主题的专用用例/脚本，或脚本尚未在 CI 实际运行（如 01-25~01-29、04 系列）。
- 03-39~03-62 的映射由 02-23~02-46 推导，实际执行时按“同编号对”成组跑用例（TEST-02/03/04 环境复用矩阵）。

## T.08.4 脚本↔用例映射表

将 `scripts/` 下与测试/检查相关的 50+ 脚本逐个映射到用例域，并标注脚本性质：

- **T（test）**：测试用例的可执行载体，产生 PASS/FAIL/SKIP 结果。
- **C（check）**：运维巡检或静态检查脚本，产出检查报告，通常不纳入 TC 编号体系。
- **E（entry）**：跨域入口脚本，内部调用多个 T/C 脚本。

| 脚本 | 性质 | 用例域 | 说明 |
| ------ | :----: | -------- | ------ |
| `aggregation-test.sh` | T | TC-INT-06/09 | 消息聚合语义验证 |
| `alert-quality-check.sh` | C | TC-OBS-07 | 告警质量周检 |
| `alerts-check.sh` | C | TC-OBS-04 | 告警链路可达性 |
| `automation-check.sh` | C | — | 自动化流程巡检 |
| `backup-verify.sh` | C | TC-DEP-15 | 备份介质完整性校验 |
| `batch-test.sh` | T | TC-INT-06 | 批处理顺序与边界 |
| `benchmark-all.sh` | E | TC-CLU-09 | 八系统基准入口 |
| `benchmark.sh` | T | TC-CLU-09/10、TC-OBS-02/08 | 单系统基准 |
| `bridge-test.sh` | T | TC-INT-02 | 跨协议桥接 |
| `capacity-check.sh` | C | — | 容量规划检查 |
| `chaos-test.sh` | T | TC-CLU-07/08、TC-CLU-06b/06c | 混沌编排与脚本化故障注入 |
| `ci-cd-check.sh` | C | — | CI/CD 配置巡检 |
| `compliance-check.sh` | C | — | 合规配置检查 |
| `compress-test.sh` | T | TC-INT-08 | 消息压缩边界 |
| `data-governance-check.sh` | C | — | 数据治理检查 |
| `degrade-check.sh` | C | — | 降级策略检查 |
| `delay-check.sh` | C | — | 延迟相关配置巡检 |
| `delay-test.sh` | T | TC-INT-11/11d/11e | 延迟注入测试 |
| `disaster-recovery-check.sh` | C | TC-DEP-12~15 | 灾备预案检查 |
| `doc-self-check.sh` | E/C | —（静态验证） | 知识库规范自检入口 |
| `documentation-check.sh` | C | — | 文档链接/格式检查 |
| `filter-test.sh` | T | TC-INT-06 | 消息过滤语义 |
| `flow-control-test.sh` | T | TC-INT-11/11d/11e | 背压/流控 |
| `health-check.sh` | C | TC-OBS-09 | 健康检查 |
| `health-check-all.sh` | E/C | TC-OBS-01 | 全系统健康巡检 |
| `idempotency-check.sh` | C | TC-INT-04 | 幂等配置巡检 |
| `idempotency-test.sh` | T | TC-INT-04 | 幂等消费行为验证 |
| `knowledge-base-check.sh` | C | — | 知识体系完整性检查 |
| `message-test.sh` | T | TC-INT-03~08/08b/08c | 端到端消息语义 |
| `monitor-alert-check.sh` | C | TC-OBS-04 | 监控告警联动检查 |
| `monitor-check.sh` | C | TC-OBS-01/02 | 监测系统检查 |
| `mq-smoke-test.sh` | E/T | TC-DEP-01~04 | 六系统冒烟入口 |
| `multi-tenant-check.sh` | C | — | 多租户配置检查 |
| `partition-check.sh` | C | TC-CLU-01/04 | 分区状态巡检 |
| `partition-test.sh` | T | TC-CLU-01/04 | 分区故障/重分配行为 |
| `performance-test.sh` | T | TC-CLU-10 | 压测至拐点 |
| `priority-test.sh` | T | TC-INT-06 | 消息优先级 |
| `rate-limit-check.sh` | C | — | 限流配置检查 |
| `retry-test.sh` | T | TC-INT-05 | 重试风暴/退避行为 |
| `routing-test.sh` | T | TC-INT-06 | 消息路由语义 |
| `schema-check.sh` | T/C | TC-INT-01 | Schema 兼容校验 |
| `security-check.sh` | C | — | 安全配置巡检 |
| `serialization-test.sh` | T | TC-INT-01/02 | 序列化/反序列化边界 |
| `storage-check.sh` | C | TC-CLU-06 | 存储健康巡检 |
| `test-connection.sh` | T | TC-DEP-01~04 | 连接性最小验证 |
| `trace-check.sh` | C | TC-OBS-03/11 | 链路追踪配置检查 |
| `trace-test.sh` | T | TC-OBS-03 | 链路追踪端到端验证 |
| `transaction-test.sh` | T | TC-INT-07/08b | 事务语义 |
| `transform-test.sh` | T | TC-INT-02 | 消息转换/CloudEvents |
| `upgrade-check.sh` | C | TC-DEP-09/10/11b/11c | 升级预检 |
| `version-compat-check.sh` | C | TC-INT-01/TC-DEP-09 | 版本兼容性检查 |

性质边界说明：同一业务主题常有 `*-test.sh` 与 `*-check.sh` 并存——前者产生行为验证结果，后者检查配置/参数是否符合基线，二者互补而非重复。`doc-self-check.sh` 与 `mq-smoke-test.sh` 作为入口，归入 E/C 与 E/T，因为它们既可独立执行，也可被更高层 harness 调用。

## T.08.5 覆盖统计口径

本节的公式只定义统计口径，具体数值由 `test-harness.sh` 与 `doc-coverage-check.sh` 在运行时产出（本文档不维护实时数字）。

```text
文档族覆盖率 = 已映射验证的文档族数 / 全文档族数
           = (● 行数) / (● 行数 + ○ 行数 + 未映射行数)

用例执行率 = 当期实际执行的 TC 用例数 / 当期计划执行的 TC 用例数
用例通过率 = PASS 数 / (PASS + FAIL)        # SKIP 不计入分母

脚本自动化率 = 有对应 *-test.sh 的 TC 用例数 / TC 用例总数
静态检查覆盖率 = 受 doc-self-check.sh 检查的文档数 / 全文档数
```

统计产物约定：

```bash
# 1) 文档族覆盖表（由 doc-coverage-check.sh 输出）
./topics/scripts/doc-coverage-check.sh --family > /tmp/doc-coverage.tsv

# 2) 用例执行结果（由 test-harness.sh 输出）
./topics/scripts/test-harness.sh --report-json > /tmp/test-report.json

# 3) 脚本→用例可机读注册表（由主代理制作）
#    见 topics/scripts/test-registry.tsv
```

覆盖状态的可视化建议：在 PROJECT_STATUS.md 质量保证节中维护一张“文档族 × 验证域”热图，每月更新一次；热图中每个单元格取 ●/○/空白 三态，与本文 T.08.3 矩阵保持一致。

## T.08.6 已知缺口与补全计划

当前映射尚未覆盖或仅部分覆盖的文档族如下：

| 缺口文档族 | 当前状态 | 建议补全方式 | 优先级 |
| ------------ | ---------- | -------------- | :------: |
| 04-01~04-05 动态系统论 | ○ 仅混沌/重试用例间接覆盖 | 新增 TC-DYN-01~03：因果回路图参数校准、故障传播方程实测、反脆弱边界验证 | P1 |
| 01-25~01-29 前沿专章 | ○ 仅静态检查 | 新增 TC-INT-13（Serverless 事件源）、TC-INT-14（AI 流式推理）等专章用例 | P2 |
| AI_Skill 系列 | ○ 仅 --skill-drift | 为每个 skill 增加“派生内容 vs 源文档”一致性用例，编号 TC-SKILL-01~07 | P2 |
| 02-33~02-42 桥接/流处理/安全/多活 | ○ 部分脚本存在但缺系统用例 | 补齐 TC-INT-02 桥接矩阵、TC-CLU-02 多活切换、TC-SEC-01 安全基线 | P1 |
| 元文档（ROADMAP/STATUS/CHANGELOG 等） | 静态检查覆盖 | 增加 TC-GOV-01：统计数字与实地计数对账 | P3 |
| config-templates/ 中 58 个模板 | ○ 仅抽样验证 | 为每系统模板增加静态断言脚本，纳入 TC-DEP-05~08 子项 | P1 |

缺口处理原则：

- 不因为缺口而阻塞现有已映射用例的执行；缺口按优先级分批补入 ROADMAP 后续滚动项。
- 新增用例必须先落到 TEST-02/03/04/07 的编号体系（或按上表建议的新子域），再回写到本文映射矩阵。
- 04 系列作为项目特色资产，其验证方式应保留“理论模型 → 实验校准 → 回写参数”的闭环（TEST-01 T.01.6 已有接口）。

## T.08.7 参考来源

- 项目内：[TEST-01](TEST-01-测试体系总览与分层策略.md)、[TEST-02](../01-部署用例/TEST-02-运维部署测试用例.md)、[TEST-03](../02-集成用例/TEST-03-集成测试用例.md)、[TEST-04](../03-集群用例/TEST-04-集群测试验证.md)、[TEST-05](../05-体系与机制/TEST-05-测试纠正与修正机制.md)、[TEST-06](../05-体系与机制/TEST-06-自我验证机制与脚本说明.md)、[TEST-07](../04-可观测用例/TEST-07-可观测与自治能力测试用例.md)、[AGENTS.md](../../AGENTS.md) §3.2/§4
- 项目内脚本：`topics/scripts/doc-self-check.sh`、`topics/scripts/mq-smoke-test.sh`、`topics/scripts/chaos-test.sh`、`topics/scripts/validate-config.sh`、`topics/scripts/benchmark-all.sh` 等
- 可机读映射：`topics/scripts/test-registry.tsv`（由主代理维护）

---

**最后更新**: 2026-11-18
