# 1.62 Apache Pulsar 存算分离架构深度解析

> **置信口径**: 协议/规范语义 =【定理】（官方规范保证）；架构对比与工程推理 =【论证】；正文未单独标注的具体数字按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Apache Pulsar / Apache BookKeeper / Oxia 官方发布信息，核实至 2026-11。
> **定位声明**: 本文深挖 Pulsar 存算分离的工程内幕，聚焦设计原理、数据路径与故障推演；选型论证见 [1.12 Apache Pulsar 深度分析](01-12-Pulsar深度分析.md)，S3 解耦趋势与成本对比见 [1.29 S3 解耦存储消息系统分析](01-29-S3解耦存储消息系统分析.md)，术语定义见 [1.58 全局核心概念卡片总表](01-58-全局核心概念卡片总表.md)，Kubernetes 落地部署见 [3.10 Kubernetes 部署实践](../03-架构与运维实践/03-10-Kubernetes部署实践.md)。

## 目录

- [1.62 Apache Pulsar 存算分离架构深度解析](#162-apache-pulsar-存算分离架构深度解析)
  - [目录](#目录)
  - [1.62.1 三层架构内幕：Broker 无状态化实现](#1621-三层架构内幕broker-无状态化实现)
    - [Topic → Bundle → Broker 的映射机制](#topic--bundle--broker-的映射机制)
    - [Bundle 裂分与负载均衡](#bundle-裂分与负载均衡)
  - [1.62.2 BookKeeper 内幕：Ledger、Quorum 与存储格式](#1622-bookkeeper-内幕ledgerquorum-与存储格式)
    - [Ledger 与 Entry 结构](#ledger-与-entry-结构)
    - [Ensemble / Write Quorum / Ack Quorum 三角关系](#ensemble--write-quorum--ack-quorum-三角关系)
    - [Ledger 恢复协议](#ledger-恢复协议)
    - [Bookie 存储格式：Journal / EntryLog / Index 三层](#bookie-存储格式journal--entrylog--index-三层)
  - [1.62.3 读写路径全追踪](#1623-读写路径全追踪)
    - [生产写入路径](#生产写入路径)
    - [消费读取路径与冷热分层](#消费读取路径与冷热分层)
    - [读缓存命中与失效](#读缓存命中与失效)
  - [1.62.4 分层存储与 Offload 工程语义](#1624-分层存储与-offload-工程语义)
    - [Offload 触发策略](#offload-触发策略)
    - [Offload 文件格式与恢复语义](#offload-文件格式与恢复语义)
    - [S3 后端一致性处理与协同](#s3-后端一致性处理与协同)
  - [1.62.5 Oxia 新元数据层](#1625-oxia-新元数据层)
    - [Oxia 架构：Raft 组、会话与顺序器](#oxia-架构raft-组会话与顺序器)
    - [Oxia 与 ZooKeeper 的容量对比依据](#oxia-与-zookeeper-的容量对比依据)
    - [Pulsar 5.0 的元数据后端选择](#pulsar-50-的元数据后端选择)
  - [1.62.6 扩容与再平衡](#1626-扩容与再平衡)
    - [Broker 上线与 Bundle 转移](#broker-上线与-bundle-转移)
    - [Bookie 扩容与 Ledgers 重分布](#bookie-扩容与-ledgers-重分布)
    - [运维操作窗口与影响面](#运维操作窗口与影响面)
  - [1.62.7 故障推演：读写可用性矩阵](#1627-故障推演读写可用性矩阵)
  - [1.62.8 设计权衡与生产要点](#1628-设计权衡与生产要点)
  - [1.62.9 参考来源](#1629-参考来源)

---

## 1.62.1 三层架构内幕：Broker 无状态化实现

Pulsar 的存算分离并非简单地把“计算”与“存储”拆成两个进程，而是在**元数据层、计算层、存储层**之间建立了严格的职责边界：

```text
┌─────────────────────────────────────────────────────────────┐
│  客户端层：Producer / Consumer / 多协议代理（Kafka/AMQP/MQTT）  │
└───────────────────────────────┬─────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│  Broker 计算层（无状态 JVM 进程）                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │ 协议解析  │  │ Topic    │  │ Managed  │  │ 负载均衡/Bundle│ │
│  │ 路由转发  │  │ Ownership│  │ Ledger   │  │ 裂分/转移     │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘ │
│       └─────────────┴─────────────┴────────────────┘          │
│  元数据后端：ZooKeeper / Oxia /（Etcd 已移除）                 │
└───────────────────────────────┬─────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│  BookKeeper 存储层（有状态 Bookie 节点）                       │
│  Journal(WAL) → WriteCache → EntryLog → IndexDB              │
│  副本策略：Ensemble / Write Quorum / Ack Quorum              │
└─────────────────────────────────────────────────────────────┘
```

Broker 不持久化消息字节，只维护三类易重建的内存状态：

1. **Topic 元数据缓存**（来自 Metadata Store）；
2. **ManagedLedger 对象**（指向 BookKeeper ledgers 的游标与索引）；
3. **当前持有的 Bundle ownership**（决定哪些 Topic 由本 Broker 服务）。

因此 Broker 进程可随时重启、水平扩展或替换，不会导致消息丢失或长时间不可用。

### Topic → Bundle → Broker 的映射机制

Pulsar 用两层映射把海量 Topic 分摊到 Broker 集群：

| 层级 | 作用 | 关键属性 |
| ------ | ------ | ---------- |
| **Topic** | 业务逻辑消息流 | `persistent://tenant/namespace/topic` |
| **Bundle** | Namespace 下的哈希区间，一组 Topic 的调度单元 | `hash(topic) ∈ [lower, upper)` |
| **Broker** | 实际持有 Bundle 并服务其 Topic | ownership 由 Metadata Store 仲裁 |

Bundle 是 Pulsar 负载均衡的最小单位，而非 Topic。一个 Namespace 默认被划分为 4 个 Bundle（可通过 `defaultNumberOfNamespaceBundles` 调整），新 Topic 按一致性哈希落到某个 Bundle，再由该 Bundle 的 owner Broker 负责所有读写请求。

```properties
# broker.conf：Bundle 默认数量与裂分阈值
defaultNumberOfNamespaceBundles=4
loadBalancerNamespaceBundleMaxTopics=1000
loadBalancerNamespaceBundleMaxSessions=1000
loadBrokerBundleThroughputOut=1000000
```

**Ownership 的获得过程**（【论证】）：

1. 客户端首次访问某 Topic，向任意 Broker 发送请求；
2. Broker 检查 Metadata Store 中 `/namespace/tenant/ns/0x00000000_0x40000000` 等 bundle 节点的 owner；
3. 若无人持有，尝试以 EPHEMERAL 方式创建 owner 节点，成功者成为 owner；
4. 非 owner Broker 返回重定向响应，客户端直连 owner Broker；
5. 客户端缓存 owner 信息，直到收到 `LookupService` 变更通知。

```bash
# 查看某 namespace 的 bundle 分布
pulsar-admin namespaces bundles public/default

# 手动卸载某个 bundle，触发重新分配
pulsar-admin namespaces unload public/default/0x00000000_0x40000000
```

### Bundle 裂分与负载均衡

当某个 Bundle 的 Topic 数、连接数或吞吐超过阈值时，LoadManager 会触发 **Bundle Split**：把一个区间裂成两个子区间，并重新分配 ownership。裂分后原 Bundle 的 Topic 按哈希进入新区间，已有连接在客户端下一次 lookup 时迁移。

```text
裂分前：Bundle A = [0x00000000, 0x80000000)
裂分后：Bundle A1 = [0x00000000, 0x40000000)
        Bundle A2 = [0x40000000, 0x80000000)
```

Pulsar 5.0 默认负载均衡器改为 **AvgShedder**（PIP-446），其设计目标是在“负载均衡收益”与“不必要的 bundle 迁移”之间取平均负载，减少因瞬态抖动导致的反复迁移。与之对比，老版 `OverloadShedder` 更容易在高负载时触发大量迁移。

| 负载均衡器 | 触发条件 | 特点 | 适用场景 |
| ---------- | -------- | ---- | -------- |
| **OverloadShedder** | Broker 资源使用超过阈值 | 反应式、迁移频繁 | 负载波动大 |
| **AvgShedder**（5.0 默认） | 集群平均负载与节点偏差 | 稳态优先、迁移少 | 一般生产环境 |
| **ThresholdShedder** | 节点间负载差超过阈值 | 中等敏感度 | 需要快速再平衡 |

```properties
# 选择负载均衡器实现
loadBalancerLoadSheddingStrategy=org.apache.pulsar.broker.loadbalance.AvgShedder
loadBalancerBundleSplitEnabled=true
loadBalancerNamespaceBundleMaxTopics=1000
loadBalancerNamespaceBundleMaxSessions=1000
```

Bundle 迁移对客户端透明，但**正在处理的 TCP 连接会被断开**，客户端需要执行 lookup 重连；因此生产环境应避免在流量峰值期间触发大规模裂分。

---

## 1.62.2 BookKeeper 内幕：Ledger、Quorum 与存储格式

BookKeeper 是 Pulsar 持久化层的核心。理解 BookKeeper 的 Ledger/Entry 模型、Quorum 机制与存储格式，是调优 Pulsar 延迟、可用性和成本的先决条件。

### Ledger 与 Entry 结构

| 概念 | 定义 | 关键属性 |
| ------ | ------ | ---------- |
| **Ledger** | BookKeeper 中追加写的逻辑日志单元 | 创建时指定 E/WQ/AQ；关闭后不可变 |
| **Entry** | Ledger 内一条记录，通常对应一批 Pulsar 消息 | 含 entry id、数据、校验和 |
| **Fragment** | Ledger 内因 ensemble 变化而切分的段 | Bookie 故障或扩容时产生新 fragment |
| **LastEntryId (LE)** | Ledger 当前最后一条 entry 的 id | 关闭 ledger 时确定 |
| **Lac (Last Add Confirmed)** | 已确认写入的最大 entry id | 消费者可见性边界 |

Pulsar 的 **ManagedLedger** 把连续的消息流切分为多个 ledgers：当 ledger 大小或时间达到阈值时关闭当前 ledger，创建新 ledger。这样单个 ledger 不会无限增长，也便于分层存储按 ledger 粒度 offload。

```java
// ManagedLedger 配置示例：ledger 滚动策略
ManagedLedgerConfig config = new ManagedLedgerConfig();
config.setMaxEntriesPerLedger(50000);      // 每个 ledger 最多 entry 数
config.setMaxSizePerLedgerMb(512);         // 每个 ledger 最大 512 MB
config.setMaximumRolloverTimeMs(120000);   // 最长 2 分钟滚动一次
```

### Ensemble / Write Quorum / Ack Quorum 三角关系

BookKeeper 用三个整数描述副本策略，这是 Pulsar 持久化保证的核心：

| 参数 | 符号 | 含义 | 典型值 |
| ---- | ---- | ---- | ------ |
| **Ensemble size** | E | 一个 ledger 涉及的 Bookie 集合大小 | 3 |
| **Write quorum** | WQ | 每条 entry 实际写入的副本数 | 3（ stripe）或 2 |
| **Ack quorum** | AQ | 返回 ACK 所需的最小确认副本数 | 2 |
| **Read quorum** | RQ | 读取时需要比对的副本数 | 2 |

三者必须满足约束（【论证】：由 BookKeeper 协议保证）：

```text
E ≥ WQ ≥ AQ ≥ 1
```

更严格的官方实现通常要求 `E > WQ > Qa` 或 `E ≥ WQ ≥ AQ`。例如默认 `E=3, WQ=3, AQ=2` 表示：

- 每条 entry 同时写 3 个 bookie（WQ=3）；
- 只要任意 2 个 bookie 返回 ACK，写即成功（AQ=2）；
- 即使 1 个 bookie 慢或宕机，写仍可在等待 2 个 ACK 后返回，避免长尾延迟。

```bash
# 设置 namespace 级持久化策略
pulsar-admin namespaces set-persistence public/default \
  --bookkeeper-ensemble 3 \
  --bookkeeper-write-quorum 3 \
  --bookkeeper-ack-quorum 2 \
  --ml-mark-delete-max-rate 0
```

| 配置 | 持久化语义 | 延迟特征 | 风险 |
| ---- | ---------- | -------- | ---- |
| E=3, WQ=3, AQ=2 | 最多丢 1 副本仍成功 | 对长尾容忍高 | 理论上存在 2 副本不一致窗口 |
| E=3, WQ=3, AQ=3 | 强一致，需全部 ACK | 受最慢 bookie 拖累 | 1 个慢节点拖慢全局吞吐 |
| E=5, WQ=2, AQ=2 | 条带化写，宽ensemble | 低延迟、高吞吐 | 副本数少，容忍故障能力弱 |

当某个 bookie 故障或写入失败时，BookKeeper client 会触发 **ensemble change**：为后续 entry 选择新的 bookie 组合，形成新的 fragment。旧 fragment 的 entry 仍保留在存活 bookie 上，故障恢复后再按副本策略补齐。

### Ledger 恢复协议

Ledger 恢复发生在 bookie 故障或 broker 异常关闭后，由 **Auditor / AutoRecovery** 组件执行：

1. **检测**：ZooKeeper/Oxia 中 bookie 的 EPHEMERAL 节点消失；
2. **审计**：Auditor 扫描该 bookie 上所有 ledgers 的 metadata（保存在 Metadata Store 中）；
3. **复制**：AutoRecovery worker 从存活副本读取缺失 entry，复制到新 bookie；
4. **元数据更新**：更新 ledger ensemble，标记片段已修复。

```bash
# 查看 ledger 复制状态
bookkeeper shell ledgermetadata -ledgerid 12345

# 手动触发 auditor 检查
bookkeeper shell autorecovery
```

恢复进度可通过 `underReplicatedLedgers` 指标监控。复制过程中**读取仍然可用**，因为 AQ 个副本已经包含完整数据；但**写入性能可能下降**，取决于剩余 bookie 的 I/O 余量。

### Bookie 存储格式：Journal / EntryLog / Index 三层

Bookie 本地磁盘分为三个逻辑层：

```text
写入路径
Producer → Broker → BookKeeper Client →
  ├─ Journal (WAL, 顺序追加, 通常 SSD)
  ├─ Write Cache (内存, 按 ledger 排序)
  └─ EntryLog (大文件追加, HDD/SSD)

读取路径
Consumer → Broker →
  ├─ Read Cache (内存, 热 entry)
  ├─ IndexDB (RocksDB, entryId → offset)
  └─ EntryLog (顺序读)
```

| 文件/组件 | 职责 | 性能特征 | 推荐介质 |
| ---------- | ---- | -------- | -------- |
| **Journal** | WAL，保证写持久化与低延迟 | 顺序写、高 IOPS | NVMe SSD |
| **Write Cache** | 聚合小写、排序后刷 entrylog | 内存操作，极快 | RAM |
| **EntryLog** | 混合存储多个 ledger 的 entry 大文件 | 顺序写、顺序读 | SSD / HDD |
| **IndexDB** | RocksDB，维护 entryId → (entryLogId, offset) | 随机读 | SSD |
| **Read Cache** | Broker 侧缓存热数据 | 命中时避免读 bookie | RAM |

```properties
# bookkeeper.conf 关键调参
journalDirectory=/data/journal
ledgerDirectories=/data/ledgers
entryLogPerLedgerEnabled=false
dbStorage_readAheadCacheBatchSize=1000
dbStorage_rocksDB_blockCacheSize=268435456
dbStorage_writeCacheMaxSizeMb=256
dbStorage_readCacheMaxSizeMb=256
```

**Journal 双写优化**：生产环境常把 journal 放在独立 NVMe 上，甚至配置多个 journal 目录以并行化 WAL 写入。EntryLog 则放在容量型 SSD 或 HDD 上，因为其主要 workload 是顺序大吞吐。

---

## 1.62.3 读写路径全追踪

### 生产写入路径

完整生产路径如下（【论证】）：

```text
1. Producer → Broker（已 lookup 到 owner）
2. Broker 将消息追加到 ManagedLedger 的当前 open ledger
3. BookKeeper client 并行发送 entry 到 WQ 个 bookie
4. 等待至少 AQ 个 bookie 返回 ACK
5. Broker 向 Producer 返回 send ACK
6. 后台：entry 进入 write cache，异步刷入 entrylog，更新 indexDB
```

```java
// Java 生产者示例：同步等待持久化 ACK
Producer<byte[]> producer = client.newProducer()
    .topic("persistent://public/default/orders")
    .sendTimeout(10, TimeUnit.SECONDS)
    .blockIfQueueFull(true)
    .create();

MessageId msgId = producer.send(orderBytes);
```

Producer 端批量策略直接影响路径效率：

| 参数 | 作用 | 建议 |
| ---- | ---- | ---- |
| `batchingEnabled` | 开启批量 | 必须开启 |
| `batchingMaxMessages` | 单批最大消息数 | 1000 |
| `batchingMaxPublishDelayMs` | 批量等待时间 | 1-10 ms |
| `compressionType` | LZ4/ZLIB/ZSTD | LZ4 或 ZSTD |

Broker 收到消息后，先进入 **Managed Ledger Entry Cache**，再交给 BookKeeper client。BookKeeper client 会维护一组 open ledgers，每个 ledger 对应一个 bookie ensemble。

### 消费读取路径与冷热分层

消费者读取时，Broker 按 subscription cursor 定位消息位置：

```text
1. Consumer 发送 FLOW 请求给 owner Broker
2. Broker 查询 cursor，得到 (ledgerId, entryId)
3. 优先从 broker read cache 读取
4. 未命中则向 bookie 发起读取请求
5. bookie 通过 indexDB 定位 entry，从 entrylog 读取
6. 返回 entry 给 broker，broker 按订阅类型推送给 consumer
```

```bash
# 查看 subscription cursor 位置
pulsar-admin topics stats persistent://public/default/orders

# 输出中 cursor 形如：markDeletePosition=12:45, readPosition=12:46
# 表示 ledger 12 的 entry 45 已确认，46 开始待投递
```

| 路径 | 数据来源 | 典型延迟 | 触发条件 |
| ---- | -------- | -------- | -------- |
| **热读** | Broker Read Cache | 亚 ms 级 | 消息刚写入、被活跃消费者读取 |
| **温读** | Bookie EntryLog + IndexDB | 1-5 ms | 消息已落盘但仍在 bookie 本地 |
| **冷读** | 分层存储（S3/GCS/OSS） | 数十-数百 ms | 消息已 offload 到对象存储 |
| **极冷读** | 需先恢复 offloaded segment | 数秒级 | backlog 极大且长期未读 |

### 读缓存命中与失效

Broker 与 Bookie 都有读缓存，命中机制不同：

- **Broker Read Cache**：缓存最近写入或读取的 entry。由于 Pulsar 的典型 workload 是“写后立即被消费”，热数据命中率很高。
- **Bookie Read Cache**：在 `dbStorage_readCacheMaxSizeMb` 控制下，缓存从 entrylog 读出的 entry。

缓存失效场景：

1. **Ledger 滚动**：新 ledger 创建后，老 ledger 数据逐渐变冷；
2. **Cursor 重置 / replay**：消费者回退到很久以前的位置，超出缓存范围；
3. **Offload 触发**：ledger 被卸载到对象存储，本地删除后缓存失效；
4. **Broker 重启**：内存缓存清空，但 bookie 层缓存仍可能命中。

```properties
# broker.conf 读缓存配置
managedLedgerCacheSizeMB=8192
managedLedgerCacheEvictionFrequency=0.1
managedLedgerCacheEvictionTimeThresholdMillis=1000
```

---

## 1.62.4 分层存储与 Offload 工程语义

Pulsar 分层存储（Tiered Storage）允许把旧的 closed ledgers 从 BookKeeper 卸载到对象存储，实现长期保留与成本优化。这与 [1.29 S3 解耦存储消息系统分析](01-29-S3解耦存储消息系统分析.md) 中讨论的 Kafka KIP-405 目标一致，但 Pulsar 的实现基于 ledger 粒度，与 BookKeeper 紧耦合。

### Offload 触发策略

触发条件由 namespace 级策略控制：

```bash
# 设置分层存储策略
pulsar-admin namespaces set-offload-threshold public/default \
  --size-threshold 10737418240  # 10 GiB

pulsar-admin namespaces set-offload-deletion-lag public/default \
  --lag 1440m                   # offload 后 1 天才删除本地副本
```

| 参数 | 含义 | 默认值 | 生产建议 |
| ---- | ---- | ------ | -------- |
| `offloadersDirectory` | offload 实现目录 | `./offloaders` | 指向挂载的 offload NAR |
| `managedLedgerOffloadAutoTriggerSizeThresholdBytes` | 自动触发大小阈值 | 0（关闭） | 按 retention 与成本设定 |
| `managedLedgerOffloadDeletionLagMs` | 本地删除延迟 | 4 小时 | 保留足够时间以应对冷读 |

Offload 由 broker 后台线程扫描 closed ledgers，当 ledger 大小超过阈值或时间超过阈值时，调用 Offloader 接口把 ledger 数据写入对象存储。

### Offload 文件格式与恢复语义

Pulsar 把 ledger 序列化为对象存储中的文件，常见实现包括：

- **S3Offloader**：使用 AWS S3 / 兼容 S3；
- **GCSOffloader**：Google Cloud Storage；
- **AzureBlobOffloader**：Azure Blob Storage；
- **FileSystemOffloader**：HDFS / POSIX 文件系统（测试用）。

```text
对象键示例：
pulsar-offload/tenant/namespace/persistent/topic/12/12.000000000000000001-000000000000000500.tiered
```

Offload 文件包含完整的 entry 序列以及校验和。恢复（readback）时：

1. Broker 发现请求的 (ledgerId, entryId) 已 offload；
2. 从 Metadata Store 读取该 ledger 的 offload 元数据（bucket、key、offset 等）；
3. 向对象存储发起范围读取请求；
4. 数据流回到 broker read cache，再投递给消费者。

```java
// 配置 S3 offload（broker.conf）
managedLedgerOffloadDriver=s3
s3ManagedLedgerOffloadBucket=my-pulsar-offload
s3ManagedLedgerOffloadRegion=us-east-1
s3ManagedLedgerOffloadServiceEndpoint=https://s3.us-east-1.amazonaws.com
```

### S3 后端一致性处理与协同

对象存储的一致性模型 historically 是最终一致，但现代云厂商 S3（2020 年后）已提供 **强一致性**：写入成功后立即可读。Pulsar offload 依赖以下假设（【论证】）：

- `PUT` 成功后，同 key 的 `GET` 立即可见；
- 若使用自托管 MinIO/Ceph 等兼容存储，需自行验证一致性；
- Offload 元数据写入 Metadata Store 与对象存储数据写入**非原子**，极端情况下需要人工删除不一致对象。

| 场景 | BookKeeper 状态 | 对象存储状态 | 处理策略 |
| ---- | --------------- | ------------ | -------- |
| offload 成功，元数据写入成功 | 保留或按 lag 删除 | 存在 | 正常 |
| offload 成功，元数据写入失败 | 保留 | 存在孤儿对象 | 需清理或重试 |
| offload 失败，元数据写入成功 | 保留 | 不存在 | 读取时回退到 bookie |
| broker 崩溃在 offload 中途 | 可能重复 | 可能不完整 | Auditor 不负责，需监控告警 |

生产建议：

1. 对 offload bucket 开启版本控制或至少开启访问日志；
2. 设置 `managedLedgerOffloadDeletionLagMs` 足够长，避免对象未就绪就删除本地副本；
3. 监控 `pulsar_storage_offloaded_bytes`、`pulsar_storage_read_rate` 等指标。


---

## 1.62.5 Oxia 新元数据层

### Oxia 架构：Raft 组、会话与顺序器

Oxia 是 Apache Pulsar 社区主导的新一代元数据与协调系统，现为 CNCF Sandbox 项目。与 ZooKeeper 的单一 leader 写模型不同，Oxia 采用**分片（sharded）架构**：

```text
Oxia 集群架构
┌─────────────────────────────────────────────┐
│  Coordinator（协调器，无状态）                │
│  - 分片分配                                   │
│  - 成员管理                                   │
│  - 不处于数据路径                            │
└─────────────────┬───────────────────────────┘
                  ↓
┌─────────────────────────────────────────────┐
│  Shard 0 ... Shard N（每个分片独立）          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│  │ Leader  │  │ Follower│  │ Follower│     │
│  │ Raft WAL│  │ Raft WAL│  │ Raft WAL│     │
│  │ LSM DB  │  │ LSM DB  │  │ LSM DB  │     │
│  └─────────┘  └─────────┘  └─────────┘     │
│  每个分片独立选举、独立持久化                 │
└─────────────────────────────────────────────┘
```

| 组件 | 职责 | 状态 |
| ---- | ---- | ---- |
| **Coordinator** | 分片分配、节点发现、leader 位置索引 | 无状态，可扩展 |
| **Shard** | 键值范围的 Raft 共识组 | 有状态，独立容错 |
| **Sequencer** | 提供单调递增序列号（类似 ZooKeeper zxid） | 可选组件，用于排序语义 |
| **Session** | 客户端会话与临时节点生命周期 | 替代 ZooKeeper ephemeral znode |

Oxia 客户端通过 coordinator 定位 key 所在 shard 的 leader，然后直接发起读写请求。 coordinator 不参与数据复制，因此不会成为写吞吐瓶颈。

### Oxia 与 ZooKeeper 的容量对比依据

官方 Oxia 文档给出的性能口径（【论证】，YCSB-style 基准，具体论文尚未发布）：

> 在同等硬件上，Oxia 可持续吞吐约为 3 节点 ZooKeeper 或 Etcd 的 **10 倍**，且接近线性扩展。

| 维度 | ZooKeeper 3.x | Oxia |
| ---- | --------------- | ---- |
| 写吞吐 | 单一 leader 瓶颈 | 分片并行，多 leader |
| 扩展性 | 垂直扩展为主 | 水平扩展 |
| 元数据大小 | 快照加载慢 | LSM 结构，更大容量 |
| 会话/临时节点 | znode + ephemeral | 原生 session |
| CAS / Watch | 支持 | 支持 |
| Pulsar 集成 | 传统默认 | 5.0 推荐默认 |

WebSearch 核实的版本事实：

- Pulsar 4.1.3（2026-02-19）将 Oxia 升级至 **0.7.2**；
- Pulsar 5.0.0（2026-10-05 GA）官方明确 Oxia 为**新生产集群的推荐元数据存储**；
- Oxia Java Client SDK 在 Maven Central 的最新可见发布为 **2026-10-17**；
- Oxia 官方文档声明完整基准数据将与后续论文一同发布。

```bash
# 查看当前 Pulsar 集群元数据后端
pulsar-admin brokers metadata

# 5.0 新集群推荐在 broker.conf 配置 Oxia
metadataStoreUrl=oxia://oxia-service:6648
# ZooKeeper 仍兼容
# metadataStoreUrl=zk:zk1:2181,zk2:2181,zk3:2181
```

### Pulsar 5.0 的元数据后端选择

| 场景 | 推荐后端 | 理由 |
| ---- | -------- | ---- |
| 新生产集群 | **Oxia** | 官方推荐，支持更大规模 topic/cursor |
| 现有 ZooKeeper 集群 | ZooKeeper → Oxia 在线迁移（PIP-454） | 支持 live migration，元数据写入短暂暂停 |
| 小规格测试/开发 | RocksDB / 内存 | 简化部署，不用于生产 |
| Etcd | **已移除**（5.0 起） | 升级前必须迁移到 ZK 或 Oxia |

---

## 1.62.6 扩容与再平衡

### Broker 上线与 Bundle 转移

新增 Broker 时，LoadManager 会按策略把部分 bundle 从负载较高的 Broker 转移到新 Broker：

```text
1. 新 Broker 启动，向 Metadata Store 注册 /loadbalance/brokers/<id>
2. LoadManager 收集各 Broker 负载（CPU、内存、网络、topic 数、bundle 数）
3. AvgShedder 计算平均负载，标记超载 Broker 上的部分 bundle
4. 触发 bundle unload，断开原 owner 的客户端连接
5. 客户端重新 lookup，新 Broker 竞争 ownership 成功
6. 流量逐渐迁移到新 Broker
```

```bash
# 手动将某个 namespace 的所有 bundle 重新平衡
pulsar-admin namespaces unload public/default

# 查看 broker 负载
pulsar-admin brokers list
pulsar-admin broker-stats load-report
```

Broker 扩容影响面：

- **无数据迁移**：因为 broker 无状态，不需要复制消息；
- **连接闪断**：bundle unload 会导致客户端 TCP 重连；
- **CPU/内存波动**：新 Broker 需要加载 topic metadata、建立 managed ledger。

### Bookie 扩容与 Ledgers 重分布

新增 Bookie 时，BookKeeper 不会立即搬迁已有 ledgers，而是让**新创建的 ledger 优先使用新 bookie**，从而逐步平衡集群。

```bash
# 扩容 bookie（以 Helm 为例）
helm upgrade pulsar apache/pulsar \
  --set bookkeeper.replicaCount=5 \
  --wait

# 查看 bookie 列表与磁盘使用
bookkeeper shell listbookies -rw
bookkeeper shell bookiesanity
```

| 扩容对象 | 是否自动重分布 | 触发方式 | 影响 |
| -------- | -------------- | -------- | ---- |
| **Broker** | 是（bundle 级） | LoadManager / 手动 unload | 连接闪断，无数据迁移 |
| **Bookie** | 否（已有 ledger 不自动迁移） | 新 ledger 自然分布 | 磁盘使用率不均衡需监控 |
| **AutoRecovery** | 是（副本修复） | Auditor 检测 under-replicated | 占用读带宽与网络 |

若需要主动让已有 ledger 分布到新 bookie，可通过以下方式：

1. 关闭并重新创建老 ledger（触发新 ensemble）；
2. 使用 `bookkeeper shell decommissionbookie` 退役旧 bookie，强制迁出数据；
3. 等待 retention 过期，自然淘汰老数据。

### 运维操作窗口与影响面

| 操作 | 建议窗口 | 影响面 | 回滚策略 |
| ---- | -------- | -------- | -------- |
| Broker 滚动升级 | 低峰期 | 单个 Broker 上 bundle 短暂不可用（秒级） | 客户端自动重连 |
| Broker 扩容 | 任意 | 新 Broker 承接新 bundle | 缩容即可 |
| Bookie 滚动升级 | 低峰期 | 单 bookie 写入副本缺失，AQ 仍满足则写可用 | 回退版本 |
| Bookie 扩容 | 任意 | 新数据自然落新 bookie | 缩容不自动迁回 |
| Bookie 退役 | 计划窗口 | AutoRecovery 复制数据，占用 I/O | 取消退役 |
| Metadata Store 升级 | 严格维护窗口 | 元数据服务不可用会导致 ownership 变更失败 | 需备份与演练 |

---

## 1.62.7 故障推演：读写可用性矩阵

Pulsar 的可用性取决于三个独立组件：Broker、Bookie、Metadata Store。以下矩阵基于默认配置 `E=3, WQ=3, AQ=2`，且 Metadata Store 为 3 节点仲裁（【论证】）。

| 故障场景 | 写入是否可用 | 读取是否可用 | 数据是否安全 | 说明 |
| -------- | ------------ | ------------ | ------------ | ---- |
| 单 Bookie 宕机 | 是 | 是 | 是 | WQ=3 剩 2 副本，AQ=2 仍满足；Auditor 触发复制 |
| 单 Bookie 慢盘 | 是 | 是 | 是 | 长尾被 AQ=2 屏蔽，但持续慢会触发 ensemble change |
| 两 Bookie 同时宕机 | 可能否 | 是 | 是 | 若恰好是同一 ledger 的 WQ 副本，写失败；读仍有 1 副本 |
| 三 Bookie 同时宕机 | 否 | 否 | 依赖是否已复制到 ≥1 副本 | 极端灾难 |
| 单 Broker 宕机 | 是 | 是 | 是 | 该 Broker 上 bundle 重新选举 owner，秒级恢复 |
| 多 Broker 宕机（< 半数） | 是 | 是 | 是 | 剩余 Broker 接管 bundle |
| 全部 Broker 宕机 | 否 | 否 | 是 | 数据在 BookKeeper 中，恢复后可用 |
| 单 ZooKeeper/Oxia 节点 | 是 | 是 | 是 | 仲裁仍有效 |
| 多 ZooKeeper/Oxia 节点（> 半数） | 否 | 否 | 是 | 无法更新 ownership/ledger 元数据 |
| Metadata Store 网络分区 | 依赖分区大小 | 依赖分区大小 | 是 | 小分区不可写，大分区可写，需防止脑裂 |

```bash
# 查看 under-replicated ledgers
bookkeeper shell listunderreplicated

# 查看 bookie 是否可读可写
bookkeeper shell listbookies -rw
bookkeeper shell listbookies -ro
```

**关键观察**：

1. Broker 故障几乎不影响持久化，只影响连接；
2. Bookie 故障影响写可用性的条件是**同一 ledger 的 WQ 副本同时损失 ≥ (WQ - AQ + 1)** 个；
3. Metadata Store 故障是“静默杀手”：读写可能在几秒后逐渐失败，因为无法创建新 ledger 或变更 ownership。

---

## 1.62.8 设计权衡与生产要点

| 权衡维度 | 选择 | 后果 |
| -------- | ---- | ---- |
| AQ=2 vs AQ=3 | AQ=2 默认 | 更好延迟与可用性，理论上存在短暂 2 副本不一致 |
| Journal SSD 容量 | 越大越好 | 允许更大数据量异步刷盘，降低抖动 |
| Bundle 数量 | 更多 bundle | 负载粒度更细，但 Metadata Store 中节点更多 |
| Offload 阈值 | 越低越激进 | 存储成本更低，但冷读延迟增加 |
| Oxia vs ZooKeeper | Oxia 用于新集群 | 更高扩展上限，但运维经验较少 |

**生产检查清单**：

- [ ] Bookie journal 与 ledger 目录分离到不同磁盘；
- [ ] `dbStorage_rocksDB_blockCacheSize` 与 `managedLedgerCacheSizeMB` 按内存容量 20-30% 配置；
- [ ] 监控 `pulsar_storage_write_latency`、`pulsar_storage_read_latency`、`bookkeeper_SERVER_WRITE_ENTRY`；
- [ ] 对分层存储 bucket 设置生命周期策略与访问日志；
- [ ] Metadata Store 必须跨 3 个故障域部署，并定期备份；
- [ ] 升级 Pulsar 5.0 前确认 etcd 已迁移到 ZooKeeper 或 Oxia。

---

## 1.62.9 参考来源

- [Apache Pulsar Architecture Overview](https://pulsar.apache.org/docs/concepts-architecture-overview/)
- [Apache BookKeeper Documentation](https://bookkeeper.apache.org/docs/)
- [The BookKeeper Protocol](https://bookkeeper.apache.org/docs/4.7.3/development/protocol/)
- [ZooKeeper and BookKeeper administration - Apache Pulsar](https://pulsar.apache.org/docs/4.0.x/administration-zk-bk/)
- [Apache Pulsar 5.0 LTS 发布博客](https://pulsar.apache.org/blog/2026/10/05/announcing-apache-pulsar-5-0/)
- [Apache Pulsar 5.0.0 Release Notes](https://pulsar.apache.org/release-notes/versioned/pulsar-5.0.0/)
- [Apache Pulsar 4.1.3 Release Notes](https://pulsar.apache.org/release-notes/versioned/pulsar-4.1.3/)
- [Configure metadata store - Oxia recommended](https://pulsar.apache.org/docs/next/administration-metadata-store/)
- [Migrate metadata store from ZooKeeper to Oxia](https://pulsar.apache.org/docs/next/administration-metadata-store-migration/)
- [What is Oxia?](https://oxia-db.github.io/docs/what-is-oxia)
- [Oxia Maven Repository](https://mvnrepository.com/artifact/io.github.oxia-db)
- [PIP-335：Support Oxia metadata store plugin](https://github.com/apache/pulsar/blob/master/pip/pip-335.md)
- [PIP-454：Migrate ZooKeeper metadata to Oxia](https://github.com/apache/pulsar/blob/master/pip/pip-454.md)
- [Inside Apache Pulsar's Millisecond Write Path](https://streamnative.io/blog/inside-apache-pulsars-millisecond-write-path-a-deep-performance-analysis)
- [Ensemble Placement Policies - Apache BookKeeper](https://bookkeeper.apache.org/docs/latest/admin/ensemble-placement/)
- [Pulsar Tiered Storage](https://pulsar.apache.org/docs/tiered-storage-overview/)
- 项目内：[1.12 Apache Pulsar 深度分析](01-12-Pulsar深度分析.md)、[1.29 S3 解耦存储消息系统分析](01-29-S3解耦存储消息系统分析.md)、[1.58 全局核心概念卡片总表](01-58-全局核心概念卡片总表.md)、[3.10 Kubernetes 部署实践](../03-架构与运维实践/03-10-Kubernetes部署实践.md)

---

**最后更新**: 2026-11-18
