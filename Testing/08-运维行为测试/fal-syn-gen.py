#!/usr/bin/env python3
# FAL 主从切换域 + SYN 复制同步域 用例生成器
# 产物：cases/fal/<sys>/TC-FAL-<SYS>-<MECH>-01.md
#       cases/syn/<sys>/TC-SYN-<SYS>-<MECH>-01.md
#       topics/scripts/test-registry.tsv 追加 domain=FAL/SYN
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "08-运维行为测试")
REGISTRY = os.path.join(ROOT, "topics", "scripts", "test-registry.tsv")

SYS_ORDER = ["KAFKA", "RABBITMQ", "NATS", "PULSAR", "ROCKETMQ", "REDIS", "MQTT"]

FAL_KB = [
    # KAFKA
    ("KAFKA", "LEADER", "leader 选举", "RF=3 分区，识别当前 leader broker 并 kill -9", "持续生产 acks=all，RTO 计时", [
        "ISR 在 replica.lag.time.max.ms + controller 通知周期内完成重选，RTO≤30s【估算】",
        "已 ack 消息 offset 连续，leader-epoch-checkpoint 单调递增",
        "脑裂防护：非 ISR 副本因 unclean.leader.election.enable=false 无法竞选；min.insync.replicas=2 保证分区 minority 侧不可写",
        "数据一致性：新 leader HW 不小于原 leader 崩溃前已提交 HW"
    ], "01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch"),
    ("KAFKA", "KRAFT", "KRaft 控制器转移", "KRaft 3 节点 controller quorum，kill active controller", "并发创建 topic / 分区重分配", [
        "新 controller leader 在 Raft 选举超时内产生，元数据只读窗口≤5s【估算】",
        "__cluster_metadata 日志 offset 连续，快照+回放一致",
        "脑裂防护：Raft majority 选举；minority 控制器无法提交元数据",
        "数据一致性：已提交元数据变更在切换后仍可见，无悬挂分区"
    ], "01-61 §1.61.4 KRaft 元数据日志"),
    ("KAFKA", "PREFERRED", "preferred leader 恢复", "将分区 leader 迁移至非 preferred replica 后触发 preferred leader election", "kill 当前 leader", [
        "preferred replica 重新被选举为 leader，RTO≤60s【估算】",
        "无 unclean leader election 发生",
        "脑裂防护：controller 仲裁，仅 ISR 内 preferred replica 可当选",
        "数据一致性：切换前后 HW 不后退"
    ], "01-61 §1.61.2 ISR/复制协议"),
    # RABBITMQ
    ("RABBITMQ", "QUORUM", "quorum 队列 leader 转移", "3 节点 quorum queue，stop leader 成员容器", "持续发布 + 消费", [
        "剩余成员在 Raft 选举超时内选出新 leader，RTO≤10s【估算】",
        "已 publisher-confirm 的消息不丢，队列深度一致",
        "脑裂防护：quorum queue Raft 多数派；minority 成员拒绝服务",
        "数据一致性：Raft log term/index 单调，无日志分歧"
    ], "01-61 §1.61.3 Leader Epoch（Raft 工程类比）/ 01-63 §1.63.7 RabbitMQ 语义对照"),
    ("RABBITMQ", "MIRROR", "经典镜像队列提升", "经典镜像队列（ha-mode:exactly）kill master 节点", "slave 提升", [
        "promoted slave 接管，未同步消息数量可观测",
        "脑裂防护：cluster_partition_handling=pause_minority 时 minority 分区暂停写；=autoheal 需人工确认对账",
        "数据一致性：持久化镜像消息在存活副本上 md5 一致；非持久化消息丢失符合声明"
    ], "01-63 §1.63.7 六系统语义能力对照 / 01-61 §1.61.2 复制协议（镜像工程类比）"),
    # NATS
    ("NATS", "STEPDOWN", "JetStream R3 stream leader stepdown", "JetStream R3 stream，使用 nats-cli 发起 stream cluster step-down", "RTO 计时", [
        "新 leader 在 5s 内产生，stream info 中 leader 名称更新",
        "已 ack 消息的 stream sequence 连续",
        "脑裂防护：R3 Raft 多数派；分区 minority 副本不可写",
        "数据一致性：消费者 ack 状态与消息序列在新 leader 上一致"
    ], "01-63 §1.63.7 NATS 语义对照 / §1.63.1 交付语义"),
    ("NATS", "METALEADER", "JetStream meta leader 切换", "JetStream 元数据 leader（meta leader）step-down", "创建 stream / 更新 consumer", [
        "元数据操作在 Raft 选举后恢复，只读窗口≤5s【估算】",
        "stream ownership 无悬挂",
        "脑裂防护：meta group Raft 多数派",
        "数据一致性：所有 stream/consumer 状态切换后一致"
    ], "01-63 §1.63.7 NATS 语义对照"),
    # PULSAR
    ("PULSAR", "BROKERSW", "broker 切换", "topic owner broker 进程 kill -9", "producer/consumer 持续读写", [
        "bundle ownership 在 metadata store 超时后释放，新 broker 获取 ownership，RTO≤10s【估算】",
        "客户端 lookup 重定向成功，TCP 重连后无消息丢失",
        "脑裂防护：ownership 由 ZooKeeper/Oxia EPHEMERAL 节点仲裁；旧 owner 会话失效后无法继续服务",
        "数据一致性：消息持久在 BookKeeper，切换不丢已 ack 消息"
    ], "01-62 §1.62.1 Broker 无状态化 / §1.62.7 故障推演"),
    ("PULSAR", "BOOKIE", "bookie 失效→ledger 恢复", "停止一个 bookie（E=3, WQ=3, AQ=2）", "Auditor/AutoRecovery 触发 ledger 恢复", [
        "写入仍可用（AQ=2 满足），后续 entry ensemble 替换为新 bookie",
        "underReplicatedLedgers 在恢复完成后归零",
        "脑裂防护：ledger ensemble 元数据由 metadata quorum 维护；单 bookie 不会导致双主",
        "数据一致性：AutoRecovery 从存活副本复制缺失 entry，entry 校验和通过"
    ], "01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 读写可用性矩阵"),
    # ROCKETMQ
    ("ROCKETMQ", "MASTERFAIL", "broker 主从切换", "broker 主从部署（master-slave sync_flush）kill master", "slave 提升", [
        "slave 在 namesrv 路由更新后承接写，RTO≤30s【估算】【论证】",
        "已 commit 消息（同步复制）在 slave 上可读",
        "脑裂防护：namesrv 路由仲裁 + HA 地址唯一；分区期间仅 majority 侧可写",
        "数据一致性：同步复制下 master/slave commitlog 一致；异步复制下未同步消息可观测"
    ], "01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）【论证】"),
    ("ROCKETMQ", "SYNCROLE", "主从同步角色切换", "手动将 slave 提升为 master（brokerRole 变更 + namesrv 注册）", "原 master 恢复后作为 slave 挂回", [
        "角色切换后客户端路由表更新，生产可继续",
        "原 master 同步新 master 增量",
        "脑裂防护：namesrv 维护 brokerId=0 唯一；同时存在两个 brokerId=0 时告警",
        "数据一致性：切换前后消费位点 offset 不跳跃"
    ], "01-63 §1.63.7 RocketMQ 语义对照【论证】"),
    # REDIS
    ("REDIS", "SENTINEL", "哨兵 failover", "Redis 一主两从 + Sentinel×3，kill master", "sentinel 自动 promote replica", [
        "sentinel 达成 quorum 后切换，RTO≤10s【估算】",
        "已写数据在 AOF everysec 模式下丢失窗口≤1s（声明边界）",
        "脑裂防护：sentinel quorum + min-replicas-to-write；分区 minority 主库降级只读",
        "数据一致性：新主库 keys 与旧主一致，replicas 重新 psync"
    ], "01-63 §1.63.7 Redis Stream 语义对照 / §1.63.1 交付语义"),
    ("REDIS", "MANUAL", "副本手动提升 REPLICAOF NO ONE", "对 replica 执行 REPLICAOF NO ONE", "原 master 恢复后重新挂为 replica", [
        "新 master 可写，其余副本 REPLICAOF 指向新 master",
        "脑裂防护：Sentinel 或人工脚本保证同时仅一个 master 可写；客户端配置切换",
        "数据一致性：手动切换前已同步数据一致，切换后 offset 连续"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
    # MQTT
    ("MQTT", "SESSION", "broker 单点重启会话恢复", "mosquitto 单节点，cleanSession=false 客户端连接并订阅 QoS1", "kill broker 后重启", [
        "客户端无感重连，订阅与会话状态恢复",
        "未 ack QoS1/2 消息按协议重投",
        "脑裂防护：单点部署无分区双主；集群部署需外部共享存储/仲裁",
        "数据一致性：持久会话文件 round-trip 后消息顺序一致"
    ], "01-63 §1.63.1 交付语义 / §1.63.7 MQTT 语义对照"),
    ("MQTT", "CLUSTER", "MQTT broker 集群/VIP 切换", "MQTT 双节点 active/standby（共享持久会话存储或负载均衡 VIP）", "VIP 切到 standby", [
        "cleanSession=false 客户端自动重连，会话继承",
        "无重复连接风暴（退避+会话已存在）",
        "脑裂防护：共享存储单写或 LB 单主；双 active 时拒绝写",
        "数据一致性：离线 QoS1/2 消息在切换后不丢失、不重复"
    ], "01-63 §1.63.7 MQTT 语义对照"),
]

SYN_KB = [
    # 复制配置矩阵
    ("KAFKA", "ACKS0", "acks=0 行为", "producer acks=0, retries=0", "kill leader during send", [
        "producer 不等待 ack，吞吐最高，故障时丢失未落盘消息（at-most-once）",
        "broker 侧无重试义务；不承诺持久化",
        "行为符合 01-63 at-most-once 定义"
    ], "01-61 §1.61.2 acks 语义 / 01-63 §1.63.1 交付语义"),
    ("KAFKA", "ACKS1", "acks=1 行为", "producer acks=1", "leader 返回 ack 后宕机", [
        "已 ack 消息若未复制到 follower，leader 宕机后可能丢失（at-least-once 边界）",
        "消费者可读到 HW 前消息；未同步消息存在丢风险",
        "行为符合 01-63 at-least-once 定义"
    ], "01-61 §1.61.2 LEO/HW / 01-63 §1.63.1"),
    ("KAFKA", "ACKSALL", "acks=all 行为", "producer acks=all, min.insync.replicas=2, RF=3", "发送并 kill 一个 follower", [
        "只要 ISR≥2，写入成功；已 ack 消息在 ISR 内完整",
        "acks=all 提供最强持久化承诺",
        "行为符合 01-63 exactly-once 系统级基石"
    ], "01-61 §1.61.2 ISR/min.insync.replicas / 01-63 §1.63.2 幂等生产者"),
    ("REDIS", "WAIT", "WAIT 命令同步复制", "Redis 主从，producer 写后执行 WAIT numreplicas timeout", "同步复制等待", [
        "WAIT 返回前至少 N 个副本确认，否则返回实际同步副本数",
        "提供同步复制点，但非事务",
        "行为符合 01-63 at-least-once 强化"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
    ("RABBITMQ", "CONFIRM", "publisher confirm vs 事务", "同一队列分别用 publisher confirm 与 tx.select 发布持久化消息", "broker 回传 ack/nack 或 tx.commit/rollback", [
        "confirm 异步、轻量，保证消息到达队列（at-least-once），吞吐高于事务",
        "事务模式批量原子提交/回滚，吞吐低但边界清晰",
        "行为符合 01-63 RabbitMQ at-least-once / AMQP 事务范围"
    ], "01-63 §1.63.7 六系统语义能力对照 / §1.63.3 Kafka 事务（AMQP 工程类比）"),
    ("PULSAR", "SYNC", "sync vs async 持久化", "producer send 等待持久化 ack（默认持久化）", "bookie AQ 返回前", [
        "broker 等待 AQ 个 bookie 确认后才 ack producer",
        "可配置 E/WQ/AQ 调整一致性与延迟",
        "行为符合 01-62 ensemble/quorum 语义"
    ], "01-62 §1.62.2 E/WQ/AQ / 01-63 §1.63.7 Pulsar 语义对照"),
    ("NATS", "JSACK", "JetStream ack 同步点", "JetStream 发布并等待 ack", "stream 持久化后返回 ack", [
        "同步点：Publish 调用在消息写入 stream 且复制到多数副本后返回",
        "支持 timeout / 重试",
        "行为符合 01-63 NATS at-least-once"
    ], "01-63 §1.63.7 NATS 语义对照"),
    ("ROCKETMQ", "SYNC", "sync vs async 主从复制", "broker 主从 sync_master / async_master 配置", "producer 发送后 broker 返回 ack", [
        "sync_master：等待 slave 同步后才 ack；async_master：master 落盘即 ack",
        "sync 延迟高但丢数据风险低",
        "行为符合 01-63 RocketMQ at-least-once 语义【论证】"
    ], "01-63 §1.63.7 RocketMQ 语义对照【论证】"),
    ("MQTT", "QOS", "QoS0/1/2 语义", "MQTT 3.1.1/5.0 客户端分别用 QoS0/1/2 发布", "broker 回传 PUBACK/PUBREC/PUBCOMP", [
        "QoS0 无 ack（at-most-once）；QoS1 at-least-once；QoS2 协议级 exactly-once",
        "QoS2 通过四次握手去重",
        "行为符合 01-63 §1.63.1 交付语义"
    ], "01-63 §1.63.1 / §1.63.7 MQTT 语义对照"),
    # 复制滞后
    ("KAFKA", "LAG", "复制滞后可观测", "恒定速率生产，RF=3", "follower 落后达到阈值", [
        "UnderReplicatedPartitions / ReplicaFetcherLag 指标可采集",
        "lag 告警阈值 ≤ replica.lag.time.max.ms；超出则 ISR 收缩",
        "恢复后 IsrExpandsPerSec 触发，lag 归零"
    ], "01-61 §1.61.2 ISR / §1.61.7 副本落后恢复"),
    ("RABBITMQ", "LAG", "复制滞后可观测", "镜像/quorum 队列持续发布", "副本同步落后", [
        "mirror_sync_count / rabbitmq_queue_slave_pids 同步状态可观测",
        "quorum 队列 RAFT commit index diff ≤ 阈值",
        "告警阈值：未同步消息数 > 1000 或 lag > 5s"
    ], "01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.2 复制协议"),
    ("NATS", "LAG", "复制滞后可观测", "JetStream R3 stream 持续发布", "副本同步落后", [
        "stream state sequence diff / consumer ack pending 可观测",
        "nats-server route latency / JetStream  advisories 采集",
        "告警阈值：leader 与 replica sequence diff > 100"
    ], "01-63 §1.63.7 NATS 语义对照"),
    ("PULSAR", "LAG", "复制滞后可观测", "bookie 写入持续负载", "ledger 复制落后", [
        "pulsar_storage_write_latency / managedLedgerCursorBacklog 可采集",
        "bookkeeper SERVER_WRITE_ENTRY / underReplicatedLedgers 告警",
        "告警阈值：cursor backlog > 10k 或 under-replicated ledger 数 > 0 持续 60s"
    ], "01-62 §1.62.2 Ledger 恢复协议 / §1.62.7 故障推演"),
    ("ROCKETMQ", "LAG", "复制滞后可观测", "broker 主从同步复制", "slave 落后 master", [
        "slave commit offset 与 master commitlog offset diff 可采集",
        "broker slave fall behind 指标告警",
        "告警阈值：offset diff > 10000 或同步复制 RT > 1s"
    ], "01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）"),
    ("REDIS", "LAG", "复制滞后可观测", "主从持续写入", "replica 落后", [
        "INFO replication：master_repl_offset - slave_repl_offset 计算 lag",
        "告警阈值：lag 字节 > 1MB 或 slave 状态 stale",
        "慢 replica 触发 client output buffer 限制可观测"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
    ("MQTT", "LAG", "桥接/会话滞后可观测", "桥接链路 QoS1 持续发布", "桥接另一端消费落后", [
        "bridge inflight / backlog 长度可采集",
        "离线消息队列长度（persistence max_queued_messages）告警",
        "告警阈值：inflight > 20 或 queued > 1000"
    ], "01-63 §1.63.7 MQTT 语义对照"),
    # 副本一致性对拍
    ("KAFKA", "MD5", "副本内容一致性", "RF=3 同一分区写入固定消息集合", "从各 replica 导出同一段 segment", [
        "各 replica 同 offset 范围 payload md5 一致",
        "leader epoch sequence file 在各副本一致",
        "差异 offset 若存在则落在未提交区间（< HW）"
    ], "01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch"),
    ("RABBITMQ", "MD5", "副本内容一致性", "镜像队列发布持久化消息集合", "从各 mirror 拉取消息", [
        "各 mirror 消息 payload md5 一致",
        "队列深度一致（未 ack 除外）",
        "quorum 队列 RAFT log md5 摘要一致"
    ], "01-63 §1.63.7 RabbitMQ 语义对照 / 01-61 §1.61.3 Leader Epoch（Raft 类比）"),
    ("NATS", "MD5", "副本内容一致性", "JetStream R3 stream 写入固定消息集合", "从 leader 与 replica 读取同 sequence", [
        "同 sequence 消息 payload md5 一致",
        "stream state 中 message count / bytes 一致",
        "consumer ack 状态一致性"
    ], "01-63 §1.63.7 NATS 语义对照"),
    ("PULSAR", "MD5", "副本内容一致性", "E=3 写入固定 entry 集合", "从各 bookie 读取同 ledgerId:entryId", [
        "entry 数据与校验和（crc）一致",
        "Lac 进度一致",
        "差异 entry 若存在则位于未确认区间"
    ], "01-62 §1.62.2 Ledger/Entry 结构 / §1.62.2 Ledger 恢复协议"),
    ("ROCKETMQ", "MD5", "副本内容一致性", "master-slave 同步复制写入固定消息集合", "对比 commitlog 同 offset 段", [
        "master 与 slave commitlog 同段 md5 一致（sync_flush/sync_master）",
        "consume queue offset 映射一致",
        "异步模式下差异在可声明窗口内"
    ], "01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）"),
    ("REDIS", "MD5", "副本内容一致性", "主库写入固定 Stream entries", "在 replica 执行 XREAD 同 ID", [
        "同 ID entry payload md5 一致",
        "stream length / last-generated-id 一致",
        "consumer group PEL 一致"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
    ("MQTT", "MD5", "副本内容一致性", "持久会话/retained 消息写入固定集合", "broker 重启后读取", [
        "retained 消息 payload md5 一致",
        "持久会话 QoS1/2 未 ack 消息顺序一致",
        "round-trip 后无消息丢失"
    ], "01-63 §1.63.7 MQTT 语义对照"),
    # 跨集群链路
    ("KAFKA", "MM2", "MirrorMaker 2 断连恢复", "MM2 单向镜像 source→target", "断网后恢复", [
        "source offset 与 target offset 映射关系保持",
        "断连期间消息在 source 保留（按 retention），恢复后回放",
        "双向镜像时同名 topic 冲突可观测（last-write 或时间戳策略）"
    ], "01-61 §1.61.6 保留策略 / 01-63 §1.63.1 交付语义"),
    ("PULSAR", "GEO", "geo-replication 断连恢复", "两个 Pulsar 集群间开启 geo-replication", "集群间网络分区后恢复", [
        "断连期间消息在本地集群保留，恢复后按 replication backlog 回放",
        "冲突行为可配置（last-write-wins / timestamp）",
        "不丢已发布消息"
    ], "01-62 §1.62.4 分层存储 / 01-63 §1.63.1 交付语义"),
    ("NATS", "SUPER", "supercluster 分区恢复", "NATS supercluster 两个本地集群", "gateway 链路分区后恢复", [
        "分区期间各本地集群独立服务",
        "恢复后 interest 与 stream 状态同步",
        "不超出 at-least-once 重复投递"
    ], "01-63 §1.63.7 NATS 语义对照"),
    ("RABBITMQ", "FED", "federation 断连恢复", "federation upstream 绑定队列", "upstream 链路断开再恢复", [
        "断连期间消息在 upstream 队列堆积（TTL/长度策略）",
        "恢复后 buffered 消息回放至 downstream",
        "fanout 冲突（同名 binding）可观测"
    ], "01-63 §1.63.7 RabbitMQ 语义对照"),
    ("REDIS", "CCR", "跨主从复制断连恢复", "replicaof 指向远端 master", "复制链路断开再恢复", [
        "断连期间 master backlog 保留；reconnect 后优先 partial resync",
        "backlog 不足时触发 full sync",
        "数据一致性：PSYNC 后 key 集合一致"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
    ("MQTT", "BRIDGE", "桥接断连恢复", "mosquitto bridge 连接远端 broker", "桥接链路断开再恢复", [
        "断连期间 inflight QoS1/2 消息按 bridge 配置缓冲",
        "恢复后按序回放；远端去重由 QoS2 保证",
        "不丢已 publish 消息"
    ], "01-63 §1.63.7 MQTT 语义对照"),
    # 链式复制/机架感知
    ("KAFKA", "RACK", "replica placement + 机架感知", "RF=3 跨 3 个 rack（broker.rack）", "broker 故障触发重选/再平衡", [
        "replica placement 满足 rack 感知约束（同分区副本分布于不同 rack）",
        "leader 重选优先选择不同 rack 的副本",
        "rebalance 后 under-replicated 归零"
    ], "01-61 §1.61.2 ISR / §1.61.7 故障推演"),
    ("PULSAR", "RACK", "bookie 机架感知", "bookies 分布在 2+ racks，启用 ensemble placement policy", "bookie 故障", [
        "新 ensemble 跨 fault domain 选择 bookie",
        "同一 ledger WQ 副本不集中在单 rack",
        "故障域隔离保证 AQ 可用"
    ], "01-62 §1.62.2 Ensemble Placement / §1.62.7 故障推演"),
    # 额外深度
    ("KAFKA", "ISR", "ISR 收缩与扩展", "RF=3 中一个 follower 变慢", "落后超出 replica.lag.time.max.ms", [
        "ISR 收缩，IsrShrinksPerSec 触发",
        "acks=all 写入失败直到 ISR 恢复≥min.insync.replicas",
        "follower 追赶后 ISR 扩展，IsrExpandsPerSec 触发"
    ], "01-61 §1.61.2 ISR 收缩 / §1.61.7 副本落后恢复"),
    ("PULSAR", "QUORUM", "AQ=2 vs AQ=3 一致性矩阵", "E=3, WQ=3，分别配置 AQ=2 与 AQ=3", "注入 1 个慢 bookie", [
        "AQ=2 时写仍成功，容忍 1 个慢节点；AQ=3 时写失败或长尾",
        "读 quorum 比对 2 个副本，结果一致",
        "延迟与可用性权衡符合 01-62 配置表"
    ], "01-62 §1.62.2 E/WQ/AQ 三角关系"),
    ("NATS", "ACKPOLICY", "consumer ack 策略", "JetStream consumer 分别用 explicit/ackAll/none", "处理一批消息", [
        "explicit：仅 acked 消息从 deliver set 移除",
        "ackAll：批量中最大 ack 序列前消息全部确认",
        "none：broker 自动ack，无重投保证"
    ], "01-63 §1.63.7 NATS 语义对照"),
    ("REDIS", "PSYNC", "部分重同步", "replica 与 master 建立复制后断开", "在 repl_backlog 范围内 reconnect", [
        "offset 仍在 backlog 内时触发 partial resync",
        "offset 落后过多触发 full sync",
        "切换后 replication offset 连续"
    ], "01-63 §1.63.7 Redis Stream 语义对照"),
]


def ensure_trailing_newline(path):
    if not os.path.exists(path):
        return
    with open(path, "rb") as f:
        f.seek(0, 2)
        if f.tell() == 0:
            return
        f.seek(-1, 2)
        if f.read(1) != b"\n":
            with open(path, "ab") as fw:
                fw.write(b"\n")


def render(domain, sys_, code, name, given, when, thens, src):
    cid = f"TC-{domain}-{sys_}-{code}-01"
    d = os.path.join(BASE, "cases", domain.lower(), sys_.lower())
    os.makedirs(d, exist_ok=True)
    body = f"""# {cid}：{sys_} {name} 运维行为测试

> **维度**：系统={sys_} | 域={domain}（{name}）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：{src}
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- {given}

## When
- {when}

## Then
"""
    body += "".join(f"- {t}\n" for t in thens)
    body += f"""
## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/{domain.lower()}/{sys_.lower()}/{cid}.sh   # 计划打印（挂账）
```

## 关联
- {src}；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
"""
    open(os.path.join(d, cid + ".md"), "w", encoding="utf-8", newline="\n").write(body)
    return f"{cid}\t{domain}\t-\tE2\t08-运维行为测试\tpending"


def main():
    reg_rows = []
    for sys_, code, name, given, when, thens, src in FAL_KB:
        reg_rows.append(render("FAL", sys_, code, name, given, when, thens, src))
    for sys_, code, name, given, when, thens, src in SYN_KB:
        reg_rows.append(render("SYN", sys_, code, name, given, when, thens, src))

    ensure_trailing_newline(REGISTRY)
    with open(REGISTRY, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(reg_rows) + "\n")

    print(f"fal_cases={len(FAL_KB)} syn_cases={len(SYN_KB)} total={len(reg_rows)}")


if __name__ == "__main__":
    main()
