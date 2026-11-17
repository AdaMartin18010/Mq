# 1.12 Apache Pulsar深度分析

> **置信口径**: 协议/规范语义=【定理】（官方规范保证）；架构对比与工程推理=【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Apache Pulsar 官方发布信息，核实至 2026-11。

## 目录

- [1.12 Apache Pulsar深度分析](#112-apache-pulsar深度分析)
  - [目录](#目录)
  - [1.12.1 Pulsar核心架构](#1121-pulsar核心架构)
  - [1.12.2 Pulsar核心概念](#1122-pulsar核心概念)
    - [多租户命名空间](#多租户命名空间)
    - [订阅类型](#订阅类型)
    - [BookKeeper 存储层](#bookkeeper-存储层)
  - [1.12.3 Pulsar性能特性](#1123-pulsar性能特性)
  - [1.12.4 Pulsar一致性机制](#1124-pulsar一致性机制)
    - [消息投递语义](#消息投递语义)
    - [持久化保证](#持久化保证)
    - [事务支持](#事务支持)
  - [1.12.5 Pulsar与Kafka对比](#1125-pulsar与kafka对比)
    - [架构对比](#架构对比)
    - [运维对比](#运维对比)
    - [选型口径](#选型口径)
  - [1.12.6 Pulsar应用场景](#1126-pulsar应用场景)
    - [多租户 SaaS 平台](#多租户-saas-平台)
    - [地理复制场景](#地理复制场景)
    - [流处理场景](#流处理场景)
  - [1.12.7 Pulsar开发架构与程序设计](#1127-pulsar开发架构与程序设计)
    - [无状态 Broker 与开发体验](#无状态-broker-与开发体验)
    - [消息确认模式](#消息确认模式)
    - [Schema 与动态配置](#schema-与动态配置)
    - [性能编程模式](#性能编程模式)
  - [1.12.8 Pulsar 4.x/5.0 演进与 Oxia](#1128-pulsar-4x50-演进与-oxia)
    - [版本时间线](#版本时间线)
    - [5.0 关键变化](#50-关键变化)
    - [Oxia 的定位与架构意义](#oxia-的定位与架构意义)
    - [升级注意事项](#升级注意事项)
    - [参考来源链接](#参考来源链接)
  - [1.12.9 Pulsar参考资源](#1129-pulsar参考资源)
    - [官方文档](#官方文档)
    - [生产案例](#生产案例)
    - [学术资源](#学术资源)

---

## 1.12.1 Pulsar核心架构

Pulsar 采用**存储与计算分离**的三层架构：

```text
┌─────────────────────────────────────────┐
│  客户端层（Producer/Consumer/多协议适配）  │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  Broker层（无状态计算层 / 元数据接口）      │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ 消息路由  │  │ 负载均衡  │  │Managed │ │
│  │ 协议适配  │  │ 动态分配  │  │Ledger  │ │
│  └─────┬────┘  └─────┬────┘  └───┬────┘ │
│        └─────────────┴───────────┘      │
│  元数据后端：ZooKeeper / Etcd / RocksDB / Oxia │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│  BookKeeper层（持久化存储层 / 分层存储）    │
│  Journal(WAL) → WriteCache → EntryLog   │
│  副本 Ensemble (E/WQ/AQ 可配)            │
└─────────────────────────────────────────┘
```

| 层级 | 组件 | 职责 | 特点 |
| ------ | ------ | ------ | ------ |
| **客户端层** | Producer/Consumer | 消息生产消费 | 支持 Java/Go/Python/C++/Node.js，兼容 Kafka 协议 |
| **Broker层** | Broker 节点 | 消息路由、负载均衡、Schema 管理 | 无状态，可独立扩展 |
| **存储层** | BookKeeper 集群 | 消息持久化、分层存储卸载 | 顺序写入、多副本、冷热分层 |

**架构优势**：Broker 与 BookKeeper 独立扩缩容；Broker 故障不丢数据；计算/存储资源可按需优化；原生多租户隔离。

**参考来源**：

- [Pulsar Architecture](https://pulsar.apache.org/docs/concepts-architecture-overview/)
- [BookKeeper Architecture](https://bookkeeper.apache.org/docs/latest/)

---

## 1.12.2 Pulsar核心概念

### 多租户命名空间

```text
Tenant（租户）
  └── Namespace（命名空间）
      └── Topic（主题）
          └── Subscription（订阅）
```

Topic 地址格式：`persistent://tenant/namespace/topic` 或 `non-persistent://tenant/namespace/topic`。

### 订阅类型

| 类型 | 说明 | 典型场景 |
| ------ | ------ | ------ |
| **Exclusive** | 单 Consumer 独占消费 | 顺序处理 |
| **Shared** | 多 Consumer 负载均衡 | 高吞吐并行 |
| **Failover** | 主备自动切换 | 高可用顺序 |
| **Key_Shared** | 按 Key 路由到固定 Consumer | 按 Key 有序并行 |

### BookKeeper 存储层

| 概念 | 说明 |
| ------ | ------ |
| **Ledger** | 顺序写入的日志单元 |
| **Entry** | Ledger 内一条记录 |
| **Bookie** | BookKeeper 存储节点 |
| **Ensemble** | Ledger 的 Bookie 副本集合 |

BookKeeper 将多 Topic 的写入混合追加到 EntryLog，避免 Kafka 式文件碎片化；Journal（SSD）与 EntryLog（HDD/S3）分离，兼顾延迟与成本。

---

## 1.12.3 Pulsar性能特性

| 指标 | 典型值 | 说明 |
| ------ | -------- | ------ |
| **单 Topic 吞吐** | 100万+ msg/s | 取决于配置与批量策略 |
| **P50 延迟** | <5 ms | 同机房、批量写入 |
| **P99 延迟** | <20 ms | 含持久化确认 |
| **扩展性** | Broker/BookKeeper 独立扩容 | 计算与存储解耦 |

**性能优化要点**：Producer 批量发送、异步发送、合理分区数、BookKeeper Journal/Cache 调优、分层存储卸载冷数据。

**参考来源**：

- [Pulsar Performance Tuning](https://pulsar.apache.org/docs/)

---

## 1.12.4 Pulsar一致性机制

### 消息投递语义

| 语义 | 说明 | 实现方式 |
| ------ | ------ | --------- |
| **At-Most-Once** | 最多一次 | 不等待 ACK |
| **At-Least-Once** | 至少一次 | 等待 ACK，可能重复 |
| **Exactly-Once** | 恰好一次 | 幂等 Producer + 事务 |

### 持久化保证

- 消息写入 BookKeeper 多副本后返回 ACK；
- 可配置 ensemble/write-quorum/ack-quorum；
- 支持非持久化 Topic 以换取更低延迟。

### 事务支持

Pulsar 事务提供跨 Topic/Partition 的原子提交，消息对其它 Consumer 隔离，直到事务提交。

**参考来源**：

- [Pulsar Message Delivery Semantics](https://pulsar.apache.org/docs/concepts-messaging/#message-delivery-semantics)
- [Pulsar Transactions](https://pulsar.apache.org/docs/transactions/)

---

## 1.12.5 Pulsar与Kafka对比

### 架构对比

| 维度 | Kafka | Pulsar |
| ------ | ------- | -------- |
| **存储/计算** | 耦合（Broker 本地盘） | 分离（Broker + BookKeeper） |
| **Broker 状态** | 有状态 | 无状态 |
| **扩展方式** | 重分配 Partition | Broker/BookKeeper 独立扩容 |
| **多租户** | 需外部隔离 | 原生 Tenant/Namespace |
| **地理复制** | MirrorMaker 等外部方案 | 原生 Geo-replication |

### 运维对比

| 维度 | Kafka | Pulsar |
| ------ | ------- | -------- |
| **部署复杂度** | 中等（KRaft 后降低） | 高（多组件：Broker/BookKeeper/元数据） |
| **故障恢复** | Leader 重选举 | Broker 故障不影响存储 |
| **扩缩容** | 需重平衡 Partition | 无状态 Broker 快速扩容 |

### 选型口径

- **优先 Pulsar**：多租户 SaaS、跨区域复制、云原生弹性、强 Schema 治理、需要存算独立演进。
- **优先 Kafka**：生态深度依赖（如 Flink/Kafka Streams 成熟度）、团队熟悉 KRaft、单机或中小规模。
- **5.0 更新**：新集群选型应评估 Pulsar 5.0 LTS + Oxia 作为元数据后端；存量 4.x 集群可先升级后按需启用 Scalable Topics/v5 API。

---

## 1.12.6 Pulsar应用场景

### 多租户 SaaS 平台

Tenant/Namespace 提供资源、权限、配额隔离，适合为多个业务线或客户提供共享消息中台。

### 地理复制场景

原生支持跨集群复制，可配置同步/异步复制、命名空间级复制集群、自动故障转移。

### 流处理场景

Pulsar Functions 提供轻量级流处理；Pulsar SQL 支持交互式查询；多协议适配降低异构系统接入成本。

---

## 1.12.7 Pulsar开发架构与程序设计

### 无状态 Broker 与开发体验

Broker 将持久化状态外置到 BookKeeper 与 Metadata Store，内存中的 ManagedLedger 缓存可随时重建。开发者无需关注 Partition 分配、Leader 选举等细节，代码量较 Kafka 减少约 40-60%【估算】。

### 消息确认模式

- **累积确认（Cumulative Ack）**：顺序场景一次确认到当前消息，减少网络往返。
- **单条确认（Individual Ack）**：并行场景精确控制每条消息。
- **Negative Ack / Retry Topic / DLQ**：原生重试与死信机制，无需外部封装。

### Schema 与动态配置

Pulsar 内置 Schema Registry，支持 Avro/Protobuf/JSON 的演进与兼容性校验；动态配置通过 Admin API 热加载，无需重启 Broker。

### 性能编程模式

- **Zero-Copy**：Netty FileRegion 减少用户态拷贝。
- **智能批量**：按时间/数量双重窗口聚合，避免小消息导致批量失效。
- **分层存储**：热数据在 BookKeeper，冷数据自动卸载到 S3/GCS/Azure Blob。

---

## 1.12.8 Pulsar 4.x/5.0 演进与 Oxia

### 版本时间线

| 版本 | 发布时间 | 性质 | 关键定位 |
| --- | --- | --- | --- |
| **Pulsar 4.0.0** | 2024-10-21 | 第二个 LTS | Oxia 元数据插件、OpenTelemetry 全链路指标、Alpine/Java 21 镜像 |
| **Pulsar 4.1.0** | 2025-09-09 | 特性版本 | 19 个 PIP；Java 客户端最低 Java 17；Broker 缓存与限流增强 |
| **Pulsar 4.1.3** | 2026-02-19 | 补丁版本 | 依赖升级，Oxia 升级至 0.7.2 |
| **Pulsar 4.0.14** | 2026-10-05 | 维护版本 | 4.0 LTS 维护线，包含 5.0 部分性能修复的回移 |
| **Pulsar 5.0.0-M1** | 2026-06-23 | 里程碑 | Scalable Topics 与 v5 API 首个预览 |
| **Pulsar 5.0.0** | 2026-10-05 | 第三个 LTS（GA） | Scalable Topics、v5 Java 客户端、Oxia 推荐默认、显著性能提升 |
| **Pulsar 5.0.1** | 2026-10-26 | 补丁版本 | 5.0 LTS 首个维护版本 |

> 【论证】Pulsar 5.0.0 已于 2026-10-05 GA，官方定位为新的长期支持版本（LTS），5.0.1 于 2026-10-26 发布。

### 5.0 关键变化

1. **Scalable Topics（PIP-460/468/483/486 等）**
   - 通过 `topic://` 地址暴露单一逻辑流，无需预先指定分区数。
   - 运行时按 Key-range 自动 split/merge 热段与冷段，保持 per-key 顺序。
   - 需要 v5 Java 客户端或兼容客户端；v4 客户端无法使用。
   - 当前限制：5.0 不支持 Scalable Topics 的地理复制与 Replicated Subscriptions。

2. **v5 Java 客户端 API（PIP-466）**
   - 重新设计为 Stream/Queue/Checkpoint 三类消费者，语义更清晰。
   - 支持非阻塞异步接收、背压、减少 ACK 开销。
   - v5 API 也适用于现有分区/非分区 Topic，可逐步迁移。

3. **Scalable Topics Client Specification 1.0**
   - 语言无关的规范，Java v5 客户端为参考实现，其它 SDK 逐步对齐。

4. **现有工作负载的性能与可靠性提升**
   - 官方 IoT 场景基准（500 publishers / 20 Key_Shared consumers）：Pulsar 5.0.0 较 4.0.13 总吞吐提升约 1.7×，P99 端到端延迟从 202.3 s 降至 1.08 s。
   - 减少线程切换、批量提交、BookKeeper 批量读、紧凑 ACK bitmap 等优化。
   - 地理复制、Key_Shared、Failover、Shared、延迟投递、事务恢复等修复。
   - 分层存储按时间戳 seek 的冷搜索对象存储请求减少约 90%（已回移至 4.0.14/4.2.5）。

5. **运维改进**
   - 默认负载均衡策略改为 **AvgShedder**，减少不必要的 bundle 迁移。
   - 结构化日志（PIP-467）携带 topic/subscription/storage 上下文。
   - 支持关闭空闲 Topic 释放内存与指标序列而不删除数据（PIP-470）。
   - Pulsar Manager 不再维护，需迁移到其它管理工具。

6. **运行时与镜像变更**
   - 服务端要求 Java 21+，推荐 Java 25（Docker 镜像默认使用）。
   - Java 客户端要求 Java 17+（4.0.x 仍支持 Java 8/11）。
   - Docker 镜像从 `apachepulsar/pulsar-all` 改为 `apachepulsar/pulsar`，IO Connector NAR 需单独提供。
   - etcd 元数据后端已移除，升级前需迁移到 ZooKeeper 或 Oxia。

### Oxia 的定位与架构意义

**Oxia** 是 Apache Pulsar 社区推动的元数据与协调系统，现为 CNCF Sandbox 项目。它提供类似 ZooKeeper/Etcd 的线性化键值、会话、临时节点、通知、CAS 等语义，但采用**分片（sharded）架构**：每个分片拥有独立 leader、WAL 与 LSM 状态，coordinator 负责分片分配与选主，不处于数据路径。

对 Pulsar 而言：

- **消除单 RSM 瓶颈**：ZooKeeper 写吞吐受单一 leader 限制，Oxia 可水平扩展。
- **统一元数据与游标**：Oxia 可直接承载 cursor positions，减少 BookKeeper ledgers 中的游标存储复杂度。
- **支撑超大规模 Topic**：官方明确 Oxia 是**新生产集群的推荐元数据存储**，Scalable Topics 也推荐搭配 Oxia。
- **部署默认变化**：Pulsar Helm chart 与 Docker Compose 已默认使用 Oxia 作为元数据后端；ZooKeeper 仍完全兼容。

Pulsar 的 `MetadataStoreProvider` 抽象使后端切换对上层透明，已内置 ZooKeeper、Etcd、RocksDB、内存及 Oxia 实现（5.0 起移除 etcd）。

### 升级注意事项

- **4.x → 5.0 路径**：建议先升级到 4.0.x 或 4.2.x 最新维护版本，再升级 5.0.0；保留回滚窗口，升级前设置 `scalableTopicsEnabled=false` 等回滚前置项。
- **Oxia 迁移**：新集群可直接以 Oxia 启动；现有 ZooKeeper 集群可使用 PIP-454 迁移框架在线迁移。
- **客户端兼容性**：v4 Java 客户端在 5.0 集群上继续可用；使用 Scalable Topics 必须 v5 API。
- **Java 版本**：服务端 Java 21+，客户端 Java 17+；检查监控、sidecar、插件的 JDK 与镜像兼容性。

### 参考来源链接

- [Apache Pulsar 5.0 LTS 发布博客](https://pulsar.apache.org/blog/2026/10/05/announcing-apache-pulsar-5-0/)
- [Pulsar 5.0 下载页](https://pulsar.apache.org/download/)
- [Pulsar 5.0 Release Highlights](https://pulsar.apache.org/docs/next/release-highlights/)
- [Apache Pulsar 5.0.0 发布说明](https://pulsar.apache.org/release-notes/versioned/pulsar-5.0.0/)
- [Apache Pulsar 5.0.1 发布说明](https://pulsar.apache.org/release-notes/versioned/pulsar-5.0.1/)
- [Apache Pulsar 4.1.3 发布说明](https://pulsar.apache.org/release-notes/versioned/pulsar-4.1.3/)
- [Apache Pulsar 4.0.14 发布说明](https://pulsar.apache.org/release-notes/versioned/pulsar-4.0.14/)
- [Apache Pulsar 4.1 发布博客](https://pulsar.apache.org/blog/2025/09/09/announcing-apache-pulsar-4-1/)
- [Configure metadata store - Oxia recommended](https://pulsar.apache.org/docs/next/administration-metadata-store/)
- [Helm deploy with Oxia](https://pulsar.apache.org/docs/next/helm-deploy/)
- [PIP-335：Support Oxia metadata store plugin](https://github.com/apache/pulsar/blob/master/pip/pip-335.md)
- [What is Oxia?](https://oxia-db.github.io/docs/what-is-oxia)

## 1.12.9 Pulsar参考资源

### 官方文档

- [Apache Pulsar Documentation](https://pulsar.apache.org/docs/)
- [Apache BookKeeper Documentation](https://bookkeeper.apache.org/docs/)
- [Pulsar Performance Tuning](https://pulsar.apache.org/docs/)

### 生产案例

- **Yahoo!**: 使用 Pulsar 处理百万级消息
- **Splunk**: 使用 Pulsar 进行日志聚合
- **Tencent**: 使用 Pulsar 构建消息平台

### 学术资源

- [Apache Pulsar: A cloud-native, distributed messaging and streaming platform](https://arxiv.org/abs/1904.01163)
- [BookKeeper: A Distributed Log Service](https://bookkeeper.apache.org/docs/)

**关联阅读**：

- [1.62 Pulsar 存算分离架构深度解析](./01-62-Pulsar存算分离架构深度解析.md)——Broker 无状态化与 BookKeeper 存储内幕的存算分离深化
- [1.29 S3 解耦存储消息系统分析](./01-29-S3解耦存储消息系统分析.md)——分层存储/S3 offload 架构对照
- [3.10 Kubernetes 部署实践](../03-架构与运维实践/03-10-Kubernetes部署实践.md)——Pulsar 集群 K8s 落地运维

---

**参考来源**：

- Apache Pulsar 官方文档与设计文档
- Apache BookKeeper 官方文档与论文
- Yahoo!、Splunk、Tencent 等生产环境案例
- Pulsar 与 Kafka 性能对比测试数据
- [Apache Pulsar 5.0 LTS 发布博客](https://pulsar.apache.org/blog/2026/10/05/announcing-apache-pulsar-5-0/)
- [Pulsar 5.0 Release Highlights](https://pulsar.apache.org/docs/next/release-highlights/)

**最后更新**: 2026-11-18
