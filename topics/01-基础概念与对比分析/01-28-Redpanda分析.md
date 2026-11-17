# 1.28 Redpanda 分析

> **置信口径**: 协议/规范语义=【定理】（官方规范保证）；架构对比与工程推理=【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
>
> **时效声明**: 本文事实基于 Redpanda 官方文档、发布公告及 GitHub releases，核实至 2026-11。当前 Redpanda Streaming 已切换至 CalVer 版本体系，最新稳定线为 v26.2。

## 目录

- [1.28 Redpanda 分析](#128-redpanda-分析)
  - [目录](#目录)
  - [1.28.1 Redpanda 定位与架构](#1281-redpanda-定位与架构)
    - [产品定位](#产品定位)
    - [关键架构特性](#关键架构特性)
  - [1.28.2 版本演进与关键特性](#1282-版本演进与关键特性)
    - [CalVer 版本体系](#calver-版本体系)
    - [版本时间线](#版本时间线)
    - [核心特性详解](#核心特性详解)
      - [1. WASM 数据转换](#1-wasm-数据转换)
      - [2. 分层存储（Tiered Storage）](#2-分层存储tiered-storage)
      - [3. Shadowing 跨集群灾难恢复](#3-shadowing-跨集群灾难恢复)
      - [4. Iceberg / 湖仓集成](#4-iceberg--湖仓集成)
  - [1.28.3 Redpanda vs Kafka](#1283-redpanda-vs-kafka)
    - [架构与运维对比](#架构与运维对比)
    - [生态与许可证对比](#生态与许可证对比)
    - [性能数据参考](#性能数据参考)
  - [1.28.4 部署与配置示例](#1284-部署与配置示例)
    - [单节点快速启动](#单节点快速启动)
    - [生产配置片段](#生产配置片段)
    - [常用 rpk 运维命令](#常用-rpk-运维命令)
  - [1.28.5 适用场景与选型建议](#1285-适用场景与选型建议)
    - [优先考虑 Redpanda 的场景](#优先考虑-redpanda-的场景)
    - [建议继续选择 Kafka 的场景](#建议继续选择-kafka-的场景)
    - [迁移提示](#迁移提示)
  - [1.28.6 参考来源](#1286-参考来源)

---

## 1.28.1 Redpanda 定位与架构

### 产品定位

**Redpanda** 是由 Redpanda Data 开发的 Kafka API 兼容流式存储系统，2019 年起源于 Vectorized 公司。它用 C++ 重新实现了 Kafka 的 wire protocol，目标是成为 **无 JVM、无 ZooKeeper/KRaft 外部依赖、低延迟、易运维** 的 Kafka 替代方案。

**核心卖点**：

- ✅ **单二进制部署**：一个 `redpanda` 可执行文件即包含 broker、controller、Schema Registry、HTTP Proxy
- ✅ **无 JVM 与 GC**：C++ 实现，消除 JVM 堆调优和垃圾回收停顿带来的尾延迟
- ✅ **无外部协调服务**：内置 Raft 共识，不需要 ZooKeeper 或独立的 KRaft controller quorum
- ✅ **Kafka 协议兼容**：多数 Kafka 客户端、连接器、管理工具仅需修改 `bootstrap.servers`
- ✅ **thread-per-core**：基于 Seastar 框架，每 CPU 核心绑定一个线程，共享无状态设计

### 关键架构特性

| 维度 | Redpanda | 说明 |
| ------ | --------- | ------ |
| **实现语言** | C++ | 无 JVM，无 GC 停顿 |
| **并发模型** | Thread-per-core (Seastar) | 每核独立分区、内存、I/O，避免锁竞争 |
| **共识协议** | Raft（原生，每个分区一个 Raft group） | 元数据与数据复制统一使用 Raft |
| **部署形态** | 单二进制 | 内置 Schema Registry、HTTP Proxy、Admin API |
| **协议兼容** | Kafka wire protocol | 支持 Produce/Fetch/Metadata/Consumer Groups 等 |

---

## 1.28.2 版本演进与关键特性

### CalVer 版本体系

Redpanda Streaming 从 **v26** 开始采用 **CalVer（Calendar Versioning）** 风格：主版本号对应年份（`v26.x` = 2026 年发布），功能版本与补丁号继续以 `v26.1`、`v26.2`、`v26.2.x` 演进。此前的 21.x–25.x 属于旧语义化版本遗留，读者在查阅旧文档或镜像标签时可能同时看到两种口径。官方支持状态与生命周期现统一以 CalVer 序列为准。

> ⚠️ **发版渠道变更**：自 **v26.2.2** 起，Redpanda 不再在 GitHub Releases 页面发布后续补丁版本；GitHub 仅保留到 v26.2.2，新版 release notes 与下载入口迁移至官方文档站。运维人员在自动化脚本中拉取 GitHub release assets 时需要切换至 docs.redpanda.com 或 Redpanda 官方仓库源。

**当前支持矩阵（2026-11）**：

| 版本 | 发布月份 | 支持截止（Self-Hosted） | 状态 |
| ------ | ---------- | ------------------------ | ------ |
| **v26.2** | 2026-07 | 2027-07-28 | [Latest / 当前最新](https://docs.redpanda.com/streaming/current/reference/releases/) |
| v26.1 | 2026-03 | 2027-03-31 | Supported |
| v25.3 | 2025-11 | 2026-11-19 | Supported（临近 EOL） |
| v25.2 及更早 | — | 已到期 | End of life |

v26.2 的补丁版本已推进至 **v26.2.6（2026-10-22）**，但 GitHub releases 页面最新只到 **v26.2.2（2026-08-21）**，后续补丁仅在 [Redpanda Docs 发布说明](https://docs.redpanda.com/streaming/current/reference/releases/redpanda/) 中维护。

### 版本时间线

| 年份 | 版本 | 关键里程碑 |
| ------ | ------ | ----------- |
| 2021–2023 | 21.x–23.x | 早期 GA、Tiered Storage、WASM Data Transforms、企业安全 |
| 2024 | 24.x | 性能持续优化、Console 强化、云产品扩展 |
| 2025 | 25.x | **Iceberg Topics GA**、Databricks 集成、Redpanda Connect GA、Shadowing 首次发布 |
| 2026 | **26.x (CalVer)** | Cloud Topics GA、新版 Admin API、Topic UUID、Iceberg REST catalog 扩展、发版渠道迁移至 Docs 站 |

### 核心特性详解

#### 1. WASM 数据转换

Redpanda 提供 **Data Transforms** 功能，允许在 broker 内用 WebAssembly 脚本对 topic 数据进行轻量级转换（如脱敏 PII、格式规范化），避免数据反复进出外部流处理引擎。

```bash
# 生成一个示例 WASM 项目并部署
rpk wasm generate redact-pii
rpk wasm deploy ./redact-pii/dist/main.js \
  --name redact-pii-01 \
  --input-topic raw-events \
  --output-topic clean-events
```

> ⚠️ 社区版与企业版对 Data Transforms 的支持范围不同；生产环境需确认许可证覆盖。

#### 2. 分层存储（Tiered Storage）

旧日志段自动卸载到对象存储（S3/GCS/Azure），本地只保留热数据，支持长期保留与 topic 恢复。

```bash
# 创建 topic 时启用分层存储
rpk topic create logs-longterm \
  -c redpanda.remote.write=true \
  -c redpanda.remote.read=true

# v26.2 起新增 tiered_v2（beta），对象存储侧支持完整压实
rpk cluster config get default_redpanda_storage_mode_tiered_impl
```

> ⚠️ 自管集群中，分层存储属于 Enterprise 功能；社区版需购买许可证。v26.2 中 Tiered Storage v2 仍标为 beta，不建议生产部署。

#### 3. Shadowing 跨集群灾难恢复

Shadowing 是 Redpanda 内置的**企业级灾备复制**机制，在 25.3 首次发布，26.x 持续增强。它在目标（shadow）集群上以**只读 shadow topic** 形式复制源集群的 topic 数据、topic 配置、消费者组 offset、ACL 及 Schema Registry 内容，并保证 offset 与源集群一致，故障切换时无需做 offset 映射。

```bash
# 创建 shadow link（目标集群上执行）
rpk shadow create my-dr-link --config-file shadow-link.yaml

# 查看复制延迟与状态
rpk shadow status my-dr-link
```

**v26.x 主要增强**：

- **v26.2**：支持从 Confluent Schema Registry 通过 HTTP API 影子复制 schema；shadow link 支持角色同步（RBAC roles）；支持 Cloud Topics shadowing；引入 `schema_registry_sync_memory_bytes`、`shadow_link_failover_batch_size` 等配置项。
- **v26.1**：Shadowing 与 Cloud Topics 的集成准备就绪，后续在 v26.2 GA；同时修复多个 Shadow Link 在 PLAIN 认证、大量 secret 分页场景下的稳定性问题。

> ⚠️ Shadowing 为 Enterprise 功能；RPO/RTO 受网络带宽与复制延迟影响，需通过 drills 验证。【估算】典型压测场景下 RPO 可达秒级到亚秒级，但实际以自身负载为准。

#### 4. Iceberg / 湖仓集成

Redpanda 25.x 推出 **Iceberg Topics**，topic 数据可直接物化为 Apache Iceberg 表，无需额外的 ETL/ELT 管道。支持 AWS Glue、Databricks Unity Catalog、Snowflake Open Catalog、GCP BigLake 等 REST catalog。

> **时效注记（批次 87，核实至 2026-11）**：Iceberg Topics 于 **25.1 GA（2025-04，行业首个多平台 GA，[官方公告](https://www.redpanda.com/blog/redpanda-25-1-iceberg-topics-ga)）**；25.3 起 Iceberg topic 有破坏性 schema 变更（见版本表警示）。流表一体五种形态的国际全景与选型判据见 [01-70](01-70-流表一体与开放表格式收敛深度解析.md)。另：[IBM 收购 Confluent（2026-03 完成）](https://newsroom.ibm.com/2026-03-17-ibm-completes-acquisition-of-confluent,-making-real-time-data-the-engine-of-enterprise-ai-and-agents) 后，Redpanda 与 Confluent 系产品的竞争-合作关系进入新阶段，季度复核跟踪。

```bash
# 创建 Iceberg Topic
rpk topic create lakehouse-events \
  -c redpanda.iceberg.mode=distributed

# v26.2 起支持按 key/value/headers 分段配置翻译方式
rpk topic create lakehouse-events \
  -c redpanda.iceberg.mode='{"value":"value_schema_id_prefix","key":"utf8"}'
```

> ⚠️ **破坏性 schema 变更警示**：Redpanda **v25.3** 对 Iceberg Topics 引入了不兼容的表 schema 变更。升级前必须按官方迁移指南操作，否则新写入数据可能进入死信队列（DLQ）。主要影响包括：
>
> - `redpanda.timestamp` 从 `timestamp` 改为 `timestamptz`
> - `redpanda.headers.key` 从 `binary` 改为 `string`
> - Avro optionals / unions / enums 的列类型与命名规则变化
>
> 详细迁移步骤见 [Iceberg Schema Changes and Migration Guide](https://docs.redpanda.com/streaming/current/upgrade/iceberg-schema-changes-and-migration-guide/)。

---

## 1.28.3 Redpanda vs Kafka

### 架构与运维对比

| 维度 | Redpanda | Apache Kafka (4.x) | 说明 |
| ------ | --------- | ------------------- | ------ |
| **实现语言** | C++ | Scala/Java (JVM) | Redpanda 无 GC 停顿 |
| **外部依赖** | 无 | KRaft controller quorum | Redpanda 单二进制即可运行 |
| **部署组件** | 一个二进制 | broker + controller（生产常分离） | Redpanda 运维面更小 |
| **共识协议** | Raft per partition | KRaft（元数据）+ ISR 复制（数据） | Redpanda 元数据与数据统一 Raft |
| **Schema Registry / HTTP Proxy** | 内置 | 需外部组件 | Redpanda 开箱即用 |
| **尾延迟（p99）** | 通常更低且稳定 | 受 GC、page cache 影响更大 | Redpanda 在高扇出写入场景优势明显 |
| **JVM 调优** | 不需要 | 必须 | Redpanda 降低运维门槛 |

### 生态与许可证对比

| 维度 | Redpanda | Apache Kafka | 说明 |
| ------ | --------- | ------------- | ------ |
| **许可证** | BSL 1.1（社区版，4 年后转 Apache 2.0）+ 商业企业版 | Apache 2.0 | Redpanda 社区版对“对外提供托管服务”有限制 |
| **Kafka 协议覆盖** | 大部分常用 API | 完整、最新 | Redpanda 可能滞后数月到数个 KIP |
| **Kafka Streams/ksqlDB** | 可运行，但非原生 | 原生 | Redpanda 更适合作为后端 broker |
| **KIP-848 / KIP-932** | 不支持/未声明 | Kafka 4.x 引入 | 新消费组协议与队列语义差距显著 |
| **云托管服务** | Redpanda Cloud | MSK、Confluent Cloud、Aiven 等 | Kafka 选择更多 |
| **社区与生态成熟度** | 快速增长 | 10 年以上积累 | Kafka 生态仍最丰富 |

### 性能数据参考

Redpanda 官方及第三方评测的常见结论（实际数据依赖硬件与负载）：

- **p99 延迟**：Redpanda 在 NVMe SSD + 高核心数 CPU 上通常可达 **亚毫秒到数毫秒** 级，而 Kafka 在 GC 压力下可能出现数十毫秒尾延迟。
- **硬件利用率**：thread-per-core 设计让 Redpanda 更能榨取多核 NVMe 性能，单节点 CPU 利用率更高。
- **资源占用**：Redpanda 单 broker 内存占用通常低于同等规模 Kafka broker（无 JVM heap）。

> ⚠️ 性能数字对负载极度敏感。[Jack Vanlightly 2023 年的独立测试](https://jack-vanlightly.com/blog/2023/5/15/kafka-vs-redpanda-performance-do-the-claims-add-up)曾指出在某些配置下 Kafka 吞吐更高；建议以自身工作负载压测为准。

---

## 1.28.4 部署与配置示例

### 单节点快速启动

```bash
# 启动单节点开发集群
rpk container start --nodes 1

# 验证集群状态
rpk cluster info
rpk cluster brokers list
```

### 生产配置片段

```yaml
# /etc/redpanda/redpanda.yaml
redpanda:
  data_directory: /var/lib/redpanda/data
  node_id: 1
  seed_servers:
    - host: { address: rp-1.example.com, port: 33145 }
    - host: { address: rp-2.example.com, port: 33145 }
    - host: { address: rp-3.example.com, port: 33145 }
  rpc_server:   { address: 0.0.0.0, port: 33145 }
  kafka_api:    [{ address: 0.0.0.0, port: 9092 }]
  admin:        [{ address: 0.0.0.0, port: 9644 }]

rpk:
  kafka_api:
    brokers: [rp-1.example.com:9092, rp-2.example.com:9092, rp-3.example.com:9092]
  admin_api:
    addresses: [rp-1.example.com:9644, rp-2.example.com:9644, rp-3.example.com:9644]
```

### 常用 rpk 运维命令

```bash
# 创建 topic
rpk topic create orders --partitions 12 --replicas 3

# 查看 topic 消费进度
rpk topic describe orders
rpk group describe order-consumers

# 设置数据保留策略
rpk topic alter-config orders --set retention.ms=604800000

# 查看节点状态与许可证
rpk cluster brokers list
rpk cluster license info
```

---

## 1.28.5 适用场景与选型建议

### 优先考虑 Redpanda 的场景

- **低延迟敏感业务**：在线交易、风控、实时竞价等对 p99 有严格要求的流处理。
- **运维团队偏小**：希望单二进制、无 JVM、无独立 controller 层，降低学习与排障成本。
- **容器化/边缘部署**：启动快、镜像小、资源占用低，适合 Kubernetes 或边缘节点。
- **需要内置 Schema Registry/HTTP Proxy**：减少外部组件数量。
- **C++ 技术栈团队**：更偏好原生二进制、无 GC 的运行时。

### 建议继续选择 Kafka 的场景

- **重度依赖 Kafka 生态**：大量使用 Kafka Streams、ksqlDB、MirrorMaker 2、特定 Kafka Connect connector。
- **需要最新 KIP 功能**：如 KIP-848 新消费组协议、KIP-932 Share Groups（队列语义）。
- **Apache 2.0 硬性要求**：组织政策排斥 BSL 或要求纯 OSI 开源许可。
- **云托管偏好**：希望直接使用 MSK、Confluent Cloud、Aiven 等成熟托管服务。
- **超大规模分区**：Kafka KRaft 已验证支持百万级分区；Redpanda 在此场景需单独评估。

### 迁移提示

- **协议兼容**：多数 Kafka 客户端只需改 `bootstrap.servers`；但应逐一对 admin 操作、事务、幂等生产者做兼容性测试。
- **无 live 迁移**：KRaft 与 Redpanda 内部元数据格式不互通，迁移需借助 MirrorMaker 2 或 Redpanda Connect 做数据复制。
- **偏移量管理**：消费者 offsets 无法直接迁移，通常需要重置或双写过渡。

---

## 1.28.6 参考来源

- [Redpanda Docs: Release Notes Index](https://docs.redpanda.com/streaming/current/reference/releases/)
- [Redpanda Docs: Redpanda Release Notes (v26.2.2 onward)](https://docs.redpanda.com/streaming/current/reference/releases/redpanda/)
- [GitHub: redpanda-data/redpanda Releases](https://github.com/redpanda-data/redpanda/releases)
- [Redpanda Docs: Upgrade — Iceberg Schema Changes and Migration Guide](https://docs.redpanda.com/streaming/current/upgrade/iceberg-schema-changes-and-migration-guide/)
- [Redpanda Blog: 25.3 — Enterprise Disaster Recovery with Shadowing](https://www.redpanda.com/blog/25-3-enterprise-disaster-recovery)
- [Redpanda Blog: Shadow Linking — DR Replication Made Easy](https://www.redpanda.com/blog/shadow-linking-disaster-recovery-replication-made-easy)
- [Redpanda Docs: What’s New in Redpanda](https://docs.redpanda.com/streaming/current/get-started/release-notes/redpanda/)
- [Redpanda Docs: Licensing Overview](https://docs.redpanda.com/streaming/current/get-started/licensing/)
- [Conduktor: Redpanda vs Kafka — Architecture, Trade-offs](https://www.conduktor.io/glossary/redpanda-vs-kafka)
- [Jack Vanlightly: Kafka vs Redpanda Performance — Do the claims add up?](https://jack-vanlightly.com/blog/2023/5/15/kafka-vs-redpanda-performance-do-the-claims-add-up)
- [Apache Kafka KIP-932: Queues for Kafka](https://cwiki.apache.org/confluence/display/KAFKA/KIP-932%3A+Queues+for+Kafka)
- [GitHub: Redpanda BSL License](https://github.com/redpanda-data/redpanda/blob/dev/licenses/bsl.md)

---

**最后更新**: 2026-11-18
