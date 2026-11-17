# 1.28 Redpanda 分析

> **时效声明**: 本文事实基于 Redpanda 官方文档、发布公告及第三方对比评测，核实至 2026-01。当前稳定产品线为 Redpanda 25.x，社区版采用 BSL 1.1 许可证。

## 目录

- [1.28 Redpanda 分析](#128-redpanda-分析)
  - [目录](#目录)
  - [1.28.1 Redpanda 定位与架构](#1281-redpanda-定位与架构)
    - [产品定位](#产品定位)
    - [架构图](#架构图)
    - [关键架构特性](#关键架构特性)
  - [1.28.2 版本演进与关键特性](#1282-版本演进与关键特性)
    - [版本时间线](#版本时间线)
    - [核心特性详解](#核心特性详解)
      - [1. WASM 数据转换](#1-wasm-数据转换)
      - [2. 分层存储（Tiered Storage）](#2-分层存储tiered-storage)
      - [3. Iceberg / 湖仓集成](#3-iceberg--湖仓集成)
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

### 架构图

```text
┌────────────────────────────────────────────┐
│           Redpanda 单二进制集群              │
├────────────────────────────────────────────┤
│  Node-1  │  Node-2  │  Node-3              │
│  Seastar │  Seastar │  Seastar (per core)  │
│  Raft ×N │  Raft ×N │  Raft ×N             │
│  (Broker + Controller + Schema Registry    │
│   + HTTP Proxy，同一进程)                   │
└────────────────────────────────────────────┘
```

### 关键架构特性

| 维度 | Redpanda | 说明 |
| ------ | --------- | ------ |
| **实现语言** | C++ | 无 JVM，无 GC 停顿 |
| **并发模型** | Thread-per-core (Seastar) | 每核独立分区、内存、I/O，避免锁竞争 |
| **共识协议** | Raft（原生，每个分区一个 Raft group） | 元数据与数据复制统一使用 Raft |
| **部署形态** | 单二进制 | 内置 Schema Registry、HTTP Proxy、Admin API |
| **内存管理** | 自管理内存 + 大页支持 | 不依赖 OS page cache 与 JVM heap |
| **协议兼容** | Kafka wire protocol | 支持 Produce/Fetch/Metadata/Consumer Groups 等 |

---

## 1.28.2 版本演进与关键特性

### 版本时间线

| 年份 | 版本 | 关键里程碑 |
| ------ | ------ | ----------- |
| 2021 | 21.x | 早期 GA，单二进制、WASM Data Transforms Tech Preview、Tiered Storage Tech Preview |
| 2022-2023 | 22.x-23.x | 分层存储逐步成熟、多 AZ 容灾、企业级安全特性 |
| 2024 | 24.x | 性能持续优化、Redpanda Console 强化、云产品扩展 |
| 2025 | 25.x | **Iceberg Topics GA**、Databricks Unity Catalog 集成、Redpanda Connect GA、Shadowing（跨集群 DR） |
| 2026 | 25.3+ | 新版 Admin API（ConnectRPC）、Topic UUID（KIP-516）、Iceberg REST catalog 扩展 |

### 核心特性详解

#### 1. WASM 数据转换

Redpanda 提供 **Data Transforms** 功能，允许在 broker 内用 WebAssembly 脚本对 topic 数据进行轻量级转换（如脱敏 PII、格式规范化），避免数据反复进出外部流处理引擎。

```bash
# 生成一个示例 WASM 项目
rpk wasm generate redact-pii

# 部署转换脚本到指定 topic
rpk wasm deploy ./redact-pii/dist/main.js \
  --name redact-pii-01 \
  --input-topic raw-events \
  --output-topic clean-events

# 列出并移除转换
rpk wasm list
rpk wasm remove redact-pii-01
```

> ⚠️ 社区版与企业版对 Data Transforms 的支持范围不同；生产环境需确认许可证覆盖。

#### 2. 分层存储（Tiered Storage）

旧日志段自动卸载到对象存储（S3/GCS/Azure），本地只保留热数据，支持长期保留与 topic 恢复。

```bash
# 创建 topic 时启用分层存储
rpk topic create logs-longterm \
  -c redpanda.remote.write=true \
  -c redpanda.remote.read=true \
  -c redpanda.remote.recovery=true

# 对已有 topic 开启
rpk topic alter-config logs-longterm \
  --set redpanda.remote.read=true \
  --set redpanda.remote.write=true
```

> ⚠️ 自管集群中，分层存储属于 Enterprise 功能；社区版需购买许可证。

#### 3. Iceberg / 湖仓集成

Redpanda 25.x 推出 **Iceberg Topics**，topic 数据可直接物化为 Apache Iceberg 表，无需额外的 ETL/ELT 管道。支持 AWS Glue、Databricks Unity Catalog、Snowflake Open Catalog、GCP BigLake 等 REST catalog。

```bash
# 创建 Iceberg Topic
rpk topic create lakehouse-events \
  -c redpanda.iceberg.mode=distributed

# 查看 Iceberg 表元数据是否已同步到 catalog
rpk cluster config get iceberg_catalog_config
```

---

## 1.28.3 Redpanda vs Kafka

### 架构与运维对比

| 维度 | Redpanda | Apache Kafka (4.x) | 说明 |
| ------ | --------- | ------------------- | ------ |
| **实现语言** | C++ | Scala/Java (JVM) | Redpanda 无 GC 停顿 |
| **外部依赖** | 无 | KRaft controller quorum（内置，但仍需规划 controller 角色） | Redpanda 单二进制即可运行 |
| **部署组件** | 一个二进制 | broker + controller（可合并，但生产常分离） | Redpanda 运维面更小 |
| **共识协议** | Raft per partition | KRaft（元数据）+ ISR 复制（数据） | Redpanda 元数据与数据统一 Raft |
| **Schema Registry** | 内置 | 需外部 Confluent Schema Registry 或兼容实现 | Redpanda 开箱即用 |
| **HTTP Proxy** | 内置 | 需外部 REST Proxy | Redpanda 开箱即用 |
| **启动速度** | 秒级 | 数十秒级 | Redpanda 更适合容器化/Serverless |
| **尾延迟（p99）** | 通常更低且稳定 | 受 GC、page cache 影响更大 | Redpanda 在高扇出写入场景优势明显 |
| **JVM 调优** | 不需要 | 必须 | Redpanda 降低运维门槛 |

### 生态与许可证对比

| 维度 | Redpanda | Apache Kafka | 说明 |
| ------ | --------- | ------------- | ------ |
| **许可证** | BSL 1.1（社区版，4 年后转 Apache 2.0）+ 商业企业版 | Apache 2.0 | Redpanda 社区版对“对外提供托管服务”有限制 |
| **Kafka 协议覆盖** | 大部分常用 API | 完整、最新 | Redpanda 可能滞后数月到数个 KIP |
| **Kafka Connect** | 兼容多数 connector | 原生最完整 | Redpanda 需验证 broker-specific API |
| **Kafka Streams/ksqlDB** | 可运行，但非原生 | 原生 | Redpanda 更适合作为后端 broker |
| **KIP-848 新消费组协议** | 不支持/未声明 | Kafka 4.0 GA | 新协议带来增量再均衡 |
| **KIP-932 Share Groups** | 不支持/未声明 | Kafka 4.1 Preview / 4.2 GA（路线图） | 队列语义差距显著 |
| **云托管服务** | Redpanda Cloud | MSK、Confluent Cloud、Aiven 等 | Kafka 选择更多 |
| **社区与生态成熟度** | 快速增长 | 10 年以上积累 | Kafka 生态仍最丰富 |

### 性能数据参考

Redpanda 官方及第三方评测的常见结论（实际数据依赖硬件与负载）：

- **p99 延迟**：Redpanda 在 NVMe SSD + 高核心数 CPU 上通常可达 **亚毫秒到数毫秒** 级，而 Kafka 在 GC 压力下可能出现数十毫秒尾延迟。
- **硬件利用率**：thread-per-core 设计让 Redpanda 更能榨取多核 NVMe 性能，单节点 CPU 利用率更高。
- **资源占用**：Redpanda 单 broker 内存占用通常低于同等规模 Kafka broker（无 JVM heap）。

> ⚠️ 性能数字对负载极度敏感。Jack Vanlightly 2023 年的独立测试曾指出在某些配置下 Kafka 吞吐更高；建议以自身工作负载压测为准。

---

## 1.28.4 部署与配置示例

### 单节点快速启动

```bash
# 安装 rpk CLI（以 Linux 为例）
curl -1sLf https://dl.redpanda.com/public/redpanda/config/gpg.deb.asc | sudo gpg --dearmor -o /usr/share/keyrings/redpanda-archive-keyring.gpg

# 启动单节点开发集群
rpk container start --nodes 1

# 验证集群状态
rpk cluster info
rpk redpanda admin brokers list
```

### 生产配置片段

```yaml
# /etc/redpanda/redpanda.yaml
redpanda:
  data_directory: /var/lib/redpanda/data
  node_id: 1
  seed_servers:
    - host:
        address: rp-1.example.com
        port: 33145
    - host:
        address: rp-2.example.com
        port: 33145
    - host:
        address: rp-3.example.com
        port: 33145
  rpc_server:
    address: 0.0.0.0
    port: 33145
  kafka_api:
    - address: 0.0.0.0
      port: 9092
  admin:
    - address: 0.0.0.0
      port: 9644

  # 资源限制：每核一个 reactor，建议预留少量核心给 OS
  num_io_groups: 4

rpk:
  kafka_api:
    brokers:
      - rp-1.example.com:9092
      - rp-2.example.com:9092
      - rp-3.example.com:9092
  admin_api:
    addresses:
      - rp-1.example.com:9644
      - rp-2.example.com:9644
      - rp-3.example.com:9644
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
rpk redpanda admin brokers list
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

- [Redpanda Docs: What’s New in Redpanda](https://docs.redpanda.com/streaming/25.3/get-started/release-notes/redpanda/)
- [Redpanda Docs: Licensing Overview](https://docs.redpanda.com/streaming/current/get-started/licensing/overview/)
- [Redpanda Blog: Tiered Storage, Wasm Data Transforms, Protobuf](https://www.redpanda.com/blog/introducing-tiered-storage-protobuf-support-wasm-data-transforms)
- [Redpanda Blog: Cloud Summer Update 2025 — Iceberg GA](https://www.redpanda.com/blog/cloud-summer-update-2025)
- [Conduktor: Redpanda vs Kafka — Architecture, Trade-offs](https://www.conduktor.io/glossary/redpanda-vs-kafka)
- [Stribog: Redpanda vs Kafka — The Same Wire Protocol, Another System](https://stribog.com/blog/redpanda-vs-kafka-broker-without-jvm-zookeeper)
- [ACE MQ: Redpanda vs Kafka — Licence, Features, Cost, Support (2026)](https://acemq.com/compare/redpanda-vs-kafka/)
- [Jack Vanlightly: Kafka vs Redpanda Performance — Do the claims add up?](https://jack-vanlightly.com/blog/2023/5/15/kafka-vs-redpanda-performance-do-the-claims-add-up)
- [Apache Kafka KIP-932: Queues for Kafka](https://cwiki.apache.org/confluence/display/KAFKA/KIP-932%3A+Queues+for+Kafka)
- [GitHub: Redpanda BSL License](https://github.com/redpanda-data/redpanda/blob/dev/licenses/bsl.md)

---

**最后更新**: 2026-01-06
