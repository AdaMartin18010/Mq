#!/usr/bin/env python3
# PST 持久化阶梯域 + CLU 集群域 用例生成器（批次128扩展）
# 输出：Testing/08-运维行为测试/cases/{pst,clu}/<sys>/<code>/TC-{PST,CLU}-<SYS>-<CODE>-01.md
#        并追加 topics/scripts/test-registry.tsv（domain=PST/CLU）
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "08-运维行为测试")
REG = os.path.join(ROOT, "topics", "scripts", "test-registry.tsv")

# ---------------------------------------------------------------------------
# PST 持久化阶梯域：每用例必须包含丢窗上界断言
# 元组：(system, code, name, given, when, thens, src)
# ---------------------------------------------------------------------------
PST_CASES = [
    # KAFKA：acks × min.insync.replicas 组合 + log.flush 行为
    ("KAFKA", "ACK0-MIR1", "acks=0/min.insync.replicas=1 持久化阶梯",
     "3 broker KRaft，topic RF=3，producer acks=0，min.insync.replicas=1",
     "kill -9 leader broker，持续生产",
     ["producer 无 ACK 等待，leader 切换期间丢窗无界（最多为未消费/未重放段）","已发送但未落盘消息可能丢失","恢复后分区继续服务，但不承诺任何已发消息"],
     "01-61 §1.61.2 ISR/HW/acks 语义"),
    ("KAFKA", "ACK0-MIR2", "acks=0/min.insync.replicas=2 持久化阶梯",
     "3 broker KRaft，topic RF=3，producer acks=0，min.insync.replicas=2",
     "kill -9 任意 broker",
     ["acks=0 不等待任何确认，丢窗仍无界","min.insync.replicas=2 仅影响 acks=all 语义，对 acks=0 不生效","恢复后校验 log-dump 段连续"],
     "01-61 §1.61.2"),
    ("KAFKA", "ACK1-MIR1", "acks=1/min.insync.replicas=1 持久化阶梯",
     "topic RF=3，producer acks=1，min.insync.replicas=1",
     "kill -9 leader 后立即重启",
     ["最多丢失 leader 已确认但尚未复制到 follower 的批次（≤1 个 in-flight batch）","未确认批次由客户端重试","恢复后 HW 不回流"],
     "01-61 §1.61.2"),
    ("KAFKA", "ACK1-MIR2", "acks=1/min.insync.replicas=2 持久化阶梯",
     "topic RF=3，producer acks=1，min.insync.replicas=2",
     "kill -9 leader",
     ["acks=1 仍只等 leader ACK；丢窗同 ACK1-MIR1（≤1 in-flight batch）","min.insync.replicas=2 不改变 acks=1 语义，但降低 acks=all 可用阈值","旧 leader 恢复后按 Leader Epoch 截断，避免数据分歧"],
     "01-61 §1.61.2/1.61.3"),
    ("KAFKA", "ACKALL-MIR1", "acks=all/min.insync.replicas=1 持久化阶梯",
     "topic RF=3，producer acks=all，min.insync.replicas=1",
     "kill leader 与 1 follower 同时（仅剩 1 ISR）",
     ["已 ack 消息在至少 1 个 ISR 上完成 fsync/页缓存，不丢","分区因无足够 ISR 进入不可用，直至旧 leader 或 follower 恢复","unclean.leader.election.enable=false 时不选非 ISR 副本"],
     "01-61 §1.61.2"),
    ("KAFKA", "ACKALL-MIR2", "acks=all/min.insync.replicas=2 持久化阶梯",
     "topic RF=3，producer acks=all，min.insync.replicas=2",
     "kill leader",
     ["已 ack 消息至少被 2 个 ISR 确认，单点故障不丢","若第二 ISR 同时崩溃，分区不可用（但已提交数据仍在存活副本）","恢复后 ISR 追赶，HW 单调递增"],
     "01-61 §1.61.2"),
    ("KAFKA", "FLUSH-MSGS", "log.flush.interval.messages 强制刷盘行为",
     "server.properties 设置 log.flush.interval.messages=10000",
     "持续生产至 10000 条时 kill -9 leader",
     ["未达刷盘阈值的消息依赖 OS 页缓存，可能丢失","达到阈值后 fsync 落盘，kill -9 后可恢复","丢窗上界 ≤ log.flush.interval.messages 条（OS 未刷盘部分按估算）"],
     "01-61 §1.61.6"),
    ("KAFKA", "FLUSH-MS", "log.flush.interval.ms 强制刷盘行为",
     "server.properties 设置 log.flush.interval.ms=1000",
     "持续生产并周期性 kill -9 broker",
     ["每次 fsync 间隔内消息最多丢失 ≤1000ms 窗口","acks=all 下已提交消息因多副本存在仍不丢（刷盘仅影响单节点）","刷盘 scheduler 按 log.flush.scheduler.interval.ms 检查"],
     "01-61 §1.61.6"),

    # RABBITMQ：durable × message persistent 2×2
    ("RABBITMQ", "D0P0", "durable=false/persistent=false 重启矩阵",
     "声明非持久队列，发布非持久消息",
     "restart broker",
     ["队列不存在（已丢失）","消息不存在","丢窗=全部未消费消息（无持久化承诺）"],
     "01-65 RabbitMQ 持久化语义"),
    ("RABBITMQ", "D0P1", "durable=false/persistent=true 重启矩阵",
     "声明非持久队列，发布 persistent=true 消息",
     "restart broker",
     ["队列丢失，消息随之不可达","persistent 标志对非持久队列无意义","丢窗=全部未消费消息"],
     "01-65"),
    ("RABBITMQ", "D1P0", "durable=true/persistent=false 重启矩阵",
     "声明 durable 队列，发布非持久消息",
     "restart broker",
     ["队列元数据恢复（durable 队列存在）","非持久消息在内存段，重启后丢失","丢窗=重启前未落盘/未消费的非持久消息"],
     "01-65"),
    ("RABBITMQ", "D1P1", "durable=true/persistent=true 重启矩阵",
     "声明 durable 队列，发布 persistent=true 消息",
     "restart broker",
     ["队列与消息均恢复","已 confirm 消息不丢","丢窗≤未 confirm 且在内存缓冲中的消息"],
     "01-65"),

    # REDIS：AOF everysec/always/no × RDB 开关 + AOF rewrite
    ("REDIS", "AOF-ALWAYS-RDBON", "AOF always + RDB 开启 kill -9",
     "appendonly yes，appendfsync always，save 启用 RDB",
     "kill -9 redis-server 并重启",
     ["每条写入 fsync，kill -9 后最多丢失当前正在执行的命令（≤1 条）","AOF 重放后数据一致","RDB 存在但 AOF 优先加载"],
     "01-67 §持久化"),
    ("REDIS", "AOF-EVERYSEC-RDBON", "AOF everysec + RDB 开启 kill -9",
     "appendonly yes，appendfsync everysec，save 启用 RDB",
     "kill -9 redis-server 并重启",
     ["丢窗≤1s（everysec 刷盘间隔）【估算】","AOF rewrite 期间写入通过 Copy-on-Write 不阻塞","RDB 提供最近一次快照回退"],
     "01-67 §持久化/03-68"),
    ("REDIS", "AOF-NO-RDBON", "AOF no + RDB 开启 kill -9",
     "appendonly yes，appendfsync no，save 启用 RDB",
     "kill -9 redis-server 并重启",
     ["丢窗取决于 OS 刷盘节奏，可能 ≥1s（无 bounded 承诺）","RDB 快照点之后写入可能全部丢失","AOF 回滚至上次 fsync 点"],
     "01-67"),
    ("REDIS", "AOF-ALWAYS-RDBOFF", "AOF always + RDB 关闭 kill -9",
     "appendonly yes，appendfsync always，save 空",
     "kill -9 redis-server 并重启",
     ["丢窗≤1 条","无 RDB 回退，完全依赖 AOF","AOF 文件完整可重放"],
     "01-67"),
    ("REDIS", "AOF-EVERYSEC-RDBOFF", "AOF everysec + RDB 关闭 kill -9",
     "appendonly yes，appendfsync everysec，save 空",
     "kill -9 redis-server 并重启",
     ["丢窗≤1s","AOF 文件可重放至最近 fsync","RDB 关闭后恢复时间可能较长"],
     "01-67/03-68"),
    ("REDIS", "AOF-NO-RDBOFF", "AOF no + RDB 关闭 kill -9",
     "appendonly yes，appendfsync no，save 空",
     "kill -9 redis-server 并重启",
     ["丢窗无界（完全依赖 OS 刷盘）","不推荐生产使用","恢复后 aof 文件可能为空或截断"],
     "01-67"),
    ("REDIS", "AOF-REWRITE", "AOF rewrite 期间持续写入",
     "appendonly yes，appendfsync everysec，触发 BGREWRITEAOF",
     "kill -9 在 rewrite 过程中",
     ["rewrite 不阻塞写入，子进程写新 AOF，父进程继续服务","kill -9 后 Redis 选择完整旧 AOF 或新 AOF（若完成）","丢窗≤1s，rewrite 期间无额外丢窗"],
     "01-67"),

    # PULSAR/BookKeeper：E/WQ/AQ 阶梯 + sync/async
    ("PULSAR", "E3WQ3AQ2", "BookKeeper E3/WQ3/AQ2 持久化阶梯",
     "namespace persistence E=3 WQ=3 AQ=2",
     "kill -9 1 bookie",
     ["写仍成功（AQ=2 满足）","读仍可从存活 2 副本完成","丢窗=0（已 ack entry 至少 2 副本）"],
     "01-62 §1.62.2 E≥WQ≥AQ"),
    ("PULSAR", "E5WQ3AQ2", "BookKeeper E5/WQ3/AQ2 持久化阶梯",
     "namespace persistence E=5 WQ=3 AQ=2",
     "kill -9 2 bookies（落在不同故障域）",
     ["写仍成功（AQ=2 满足，且 WQ 副本落在其余 bookie）","读仍可用","容错边界优于 E3 配置"],
     "01-62 §1.62.2"),
    ("PULSAR", "E3WQ3AQ3", "BookKeeper E3/WQ3/AQ3 强一致阶梯",
     "namespace persistence E=3 WQ=3 AQ=3",
     "kill -9 1 bookie",
     ["写需全部 3 副本 ack，1 台故障即不可写","读仍可用","丢窗=0，可用性换一致性"],
     "01-62 §1.62.2"),
    ("PULSAR", "SYNC-PERSIST", "Pulsar 同步持久化 ACK",
     "producer send 等待持久化 ACK（默认）",
     "kill broker 后重连",
     ["broker 返回 ACK 前 entry 已落 BookKeeper（AQ 确认）","已 ack 消息不丢","broker 无状态，恢复后 topic ownership 重新选举"],
     "01-62 §1.62.3"),
    ("PULSAR", "ASYNC-PERSIST", "Pulsar 异步持久化 ACK",
     "producer 配置异步 ACK 或 send 不等待",
     "kill broker",
     ["丢窗≤发送缓冲区内未确认批次","broker 崩溃可能丢失尚未转存到 BookKeeper 的消息","异步 ACK 吞吐更高但丢窗更大"],
     "01-62 §1.62.3"),

    # NATS：JetStream file vs memory
    ("NATS", "JS-FILE", "JetStream File 存储重启行为",
     "Stream 存储类型=file，R=3",
     "kill -9 nats-server 并重启",
     ["流消息与消费序列持久化到磁盘，重启后恢复","已 ack 消息不丢","FileStore 校验和通过"],
     "01-66/03-68"),
    ("NATS", "JS-MEMORY", "JetStream Memory 存储重启行为",
     "Stream 存储类型=memory，R=3",
     "kill -9 nats-server 并重启",
     ["memory 流消息全部丢失（无持久化）","消费者序列重置","丢窗=全部未消费消息"],
     "01-66/03-68"),
    ("NATS", "JS-FILE-CHECKSUM", "JetStream FileStore 校验",
     "Stream 存储类型=file",
     "损坏一个 block 文件后重启",
     ["启动时 FileStore 校验和检测失败或跳过坏块","可从未损坏副本恢复（R>1）","单副本损坏需从备份恢复"],
     "01-66"),

    # ROCKETMQ：SYNC_FLUSH vs ASYNC_FLUSH
    ("ROCKETMQ", "SYNC-FLUSH", "RocketMQ SYNC_FLUSH 断电丢窗",
     "broker flushDiskType=SYNC_FLUSH",
     "kill -9 broker 模拟断电",
     ["消息刷盘后才返回 SEND_OK，丢窗≤0（已确认消息）","未确认消息可能丢失","恢复后 commitlog 校验"],
     "01-67/03-68【论证】"),
    ("ROCKETMQ", "ASYNC-FLUSH", "RocketMQ ASYNC_FLUSH 断电丢窗",
     "broker flushDiskType=ASYNC_FLUSH",
     "kill -9 broker 模拟断电",
     ["丢窗≤两次 flush 间隔（默认 500ms 或按 OS）","吞吐更高但存在落盘窗口","恢复后 commitlog 末尾可能截断"],
     "01-67/03-68【论证】"),

    # MQTT：cleanSession × QoS 0/1/2 重启矩阵
    ("MQTT", "CS1-Q0", "cleanSession=true / QoS=0 重启",
     "客户端 CONNECT Clean Start=1，订阅 QoS0",
     "broker restart",
     ["会话不存在，订阅丢失","QoS0 消息无持久化，全部丢失","丢窗=全部"],
     "01-64 §1.64.2/1.64.3【定理】"),
    ("MQTT", "CS1-Q1", "cleanSession=true / QoS=1 重启",
     "客户端 CONNECT Clean Start=1，发布/订阅 QoS1",
     "broker restart",
     ["会话状态不保留","已 PUBACK 的 QoS1 消息不补发","未确认 inflight 消息丢失"],
     "01-64【定理】"),
    ("MQTT", "CS1-Q2", "cleanSession=true / QoS=2 重启",
     "客户端 CONNECT Clean Start=1，发布/订阅 QoS2",
     "broker restart",
     ["会话状态不保留","已 PUBCOMP 的 QoS2 消息不补发","未完成的 PUBREC/PUBREL 状态丢失"],
     "01-64【定理】"),
    ("MQTT", "CS0-Q0", "cleanSession=false / QoS=0 重启",
     "客户端 CONNECT Clean Start=0 Session Expiry>0，订阅 QoS0",
     "broker restart",
     ["会话与订阅保留","QoS0 消息不持久化，重启后不可恢复","丢窗=QoS0 未投递消息"],
     "01-64【定理】"),
    ("MQTT", "CS0-Q1", "cleanSession=false / QoS=1 重启",
     "客户端 CONNECT Clean Start=0 Session Expiry>0，发布/订阅 QoS1",
     "broker restart",
     ["会话保留，未确认的 QoS1 消息在 Session Expiry 内补发","已 PUBACK 消息不重复","丢窗=0（在 Session Expiry 内）"],
     "01-64【定理】"),
    ("MQTT", "CS0-Q2", "cleanSession=false / QoS=2 重启",
     "客户端 CONNECT Clean Start=0 Session Expiry>0，发布/订阅 QoS2",
     "broker restart",
     ["会话保留，未完成的 QoS2 四步握手状态恢复","协议层恰好一次语义保持","丢窗=0（Session Expiry 内）"],
     "01-64【定理】"),

    # 扩展：持久化风险与高级阶梯
    ("KAFKA", "UNCLEAN-LEADER", "unclean.leader.election.enable 持久化风险",
     "topic RF=3，acks=all，min.insync.replicas=2；分别设置 unclean.leader.election.enable=true/false",
     "leader 与全部 ISR 同时崩溃，落后副本成为唯一存活副本",
     ["false 时分区不可用，已提交数据不丢","true 时落后副本晋升 leader，可能丢失已确认消息","丢窗=leader 崩溃前已 ack 但落后副本未复制的数据"],
     "01-61 §1.61.2"),
    ("RABBITMQ", "QUORUM-QUEUE", "RabbitMQ Quorum Queue 重启持久化",
     "声明 quorum queue，发布 persistent 消息",
     "kill -9 任意 2 节点后恢复",
     ["quorum queue 基于 Raft，多数派节点存活即可恢复","已 confirm 消息不丢","丢窗≤未确认消息"],
     "01-65"),
    ("REDIS", "RDB-ONLY", "RDB-only 持久化 kill -9",
     "save 启用 RDB，appendonly no",
     "kill -9 redis-server 并重启",
     ["丢窗≤自上次 RDB save 以来的写入","恢复后加载最近 .rdb","无 AOF 时无法 finer-grained 回滚"],
     "01-67"),
    ("PULSAR", "OFFLOAD", "Pulsar 分层存储 offload 持久化",
     "namespace 开启 offload 到 S3，closed ledger 满足阈值",
     "kill -9 bookie 并删除本地 ledger 后读取历史消息",
     ["offloaded ledger 从 S3 可读","本地删除不影响已 offload 数据","读路径回退到分层存储，延迟上升但数据完整"],
     "01-62 §1.62.4"),
    ("ROCKETMQ", "SYNC-REPLICA", "RocketMQ 主从同步复制持久化",
     "brokerRole=SYNC_MASTER，flushDiskType=SYNC_FLUSH",
     "kill master",
     ["slave 已同步 master 数据，failover 不丢已确认消息","SYNC_MASTER 等待 slave 确认后才返回 SEND_OK","丢窗≤未确认消息"],
     "01-67/03-68【论证】"),
]

# ---------------------------------------------------------------------------
# CLU 集群域：组建、成员变更、网络分区/脑裂、恢复合并
# ---------------------------------------------------------------------------
CLU_CASES = [
    # 组建
    ("KAFKA", "JOIN", "单节点→集群扩展与分区重分配",
     "1 broker → 3 broker KRaft 集群，topic RF=3",
     "新增 2 broker，执行分区重分配",
     ["新 broker 注册到 KRaft metadata","重分配后分区副本均匀分布","UnderReplicatedPartitions=0"],
     "01-61 §1.61.4/03-09"),
    ("NATS", "JOIN", "NATS 集群路由发现",
     "3 nats-server 配置 routes",
     "依次启动 server",
     ["每节点 nats-server 路由表显示 3 节点","客户端连接任意节点可发现全部","cluster size=3"],
     "01-66/03-09"),
    ("RABBITMQ", "JOIN", "RabbitMQ 集群 join 与镜像策略",
     "3 节点 RabbitMQ，rabbitmqctl join_cluster",
     "启用 ha-all 镜像策略",
     ["cluster_status 显示 3 running nodes","队列在多个节点上存在 master+mirror","策略生效后新建队列自动镜像"],
     "01-65/03-09"),
    ("PULSAR", "JOIN", "Pulsar 集群 bookie 加入",
     "3 broker + 3 bookie 集群",
     "新增 1 bookie",
     ["bookkeeper listbookies -rw 包含新节点","新 ledger ensemble 优先使用新 bookie","已有 ledger 不自动迁移（需 decommission）"],
     "01-62 §1.62.6"),
    ("REDIS", "JOIN", "Redis Cluster meet 组建",
     "6 节点（3 主 3 从）",
     "redis-cli --cluster create",
     ["cluster nodes 显示 16384 slots 全部分配","每个 master 至少 1 replica","cluster_state=ok"],
     "01-67/03-09"),
    ("ROCKETMQ", "JOIN", "RocketMQ namesrv/broker 集群加入",
     "2 namesrv + 2 broker",
     "新增 broker 并注册到 namesrv",
     ["namesrv 路由表包含新 broker","producer 缓存刷新后路由到新 broker","无单点写入中断"],
     "01-67/03-09"),
    ("MQTT", "JOIN", "MQTT 集群节点加入",
     "EMQX/HiveMQ 2 节点",
     "加入第三节点",
     ["节点列表显示 3 nodes","会话按策略分布","共享订阅跨节点负载均衡"],
     "01-64/03-09"),

    # 成员变更：优雅退出
    ("KAFKA", "GRACEFUL-EXIT", "Kafka broker 优雅退役",
     "4 broker 集群，topic RF=3",
     "kafka-reassign-partitions 迁出数据后关闭 broker",
     ["该 broker 上无 leader 分区","分区副本已全部迁移","关闭过程无 Unclean Leader"],
     "01-61/03-68"),
    ("NATS", "GRACEFUL-EXIT", "NATS 节点优雅退役",
     "3 节点 JetStream R3",
     "nats-server  lame duck / 关闭",
     ["客户端路由表更新，新连接不再进入该节点","R3 stream 重新选主","无消息丢失"],
     "01-66/03-68"),
    ("RABBITMQ", "GRACEFUL-EXIT", "RabbitMQ 节点优雅退役",
     "3 节点镜像队列集群",
     "rabbitmqctl stop_app 后退役",
     ["镜像队列在剩余节点选出新 master","正在 confirm 的消息完成","无未处理连接"],
     "01-65/03-68"),
    ("PULSAR", "GRACEFUL-EXIT", "Pulsar bookie 优雅退役",
     "4 bookie 集群",
     "bookkeeper shell decommissionbookie",
     ["该 bookie 上 ledgers 复制到其他节点","decommission 完成后可安全下线","underReplicatedLedgers 最终为 0"],
     "01-62 §1.62.6"),
    ("REDIS", "GRACEFUL-EXIT", "Redis Cluster 节点优雅退役",
     "3 主 3 从",
     "redis-cli --cluster reshard 迁空 slots 后 shutdown",
     ["目标节点 slots=0","reshard 过程中集群仍可用","客户端重定向到新的 slot owner"],
     "01-67/03-68"),
    ("ROCKETMQ", "GRACEFUL-EXIT", "RocketMQ broker 优雅退役",
     "2 broker 集群",
     "停止 broker，namesrv 注销路由",
     ["namesrv 路由表移除该 broker","producer 缓存刷新后不再发送","在途消息完成"],
     "01-67/03-68"),
    ("MQTT", "GRACEFUL-EXIT", "MQTT 集群节点优雅退役",
     "3 节点 EMQX",
     "节点 leave_cluster",
     ["会话迁移到剩余节点","共享订阅重新分配","已连接客户端触发重连"],
     "01-64/03-68"),

    # 成员变更：强制退出
    ("KAFKA", "FORCE-EXIT", "Kafka broker 强制退出",
     "4 broker 集群，topic RF=3",
     "kill -9 1 broker",
     ["Controller 将该 broker 上分区标记 under-replicated","ISR 收缩至剩余副本","恢复后追赶再入 ISR"],
     "01-61 §1.61.7"),
    ("NATS", "FORCE-EXIT", "NATS 节点强制退出",
     "3 节点 JetStream R3",
     "kill -9 1 server",
     ["剩余节点继续服务","R3 stream 降级为 R2，仍可读可写","恢复后 re-elect 补全副本"],
     "01-66"),
    ("RABBITMQ", "FORCE-EXIT", "RabbitMQ 节点强制退出",
     "3 节点镜像队列",
     "kill -9 1 node",
     ["镜像队列 master 迁移到存活节点","暂停/忽略少数派策略按 cluster_partition_handling 生效","恢复后 mirror 同步"],
     "01-65/03-68"),
    ("PULSAR", "FORCE-EXIT", "Pulsar bookie 强制退出",
     "3 bookie 集群 E3/WQ3/AQ2",
     "kill -9 1 bookie",
     ["写仍可用（AQ=2）","Auditor 标记 under-replicated ledgers","AutoRecovery 复制数据到新 bookie"],
     "01-62 §1.62.7"),
    ("REDIS", "FORCE-EXIT", "Redis Cluster 节点强制退出",
     "3 主 3 从",
     "kill -9 1 master",
     ["集群检测到 master fail","其 replica 晋升为新 master","failover 期间对应 slots 短暂不可用"],
     "01-67/03-68"),
    ("ROCKETMQ", "FORCE-EXIT", "RocketMQ broker 强制退出",
     "2 broker 集群",
     "kill -9 1 broker",
     ["namesrv 路由表仍保留直至心跳超时","producer 缓存导致部分消息发送失败","客户端更新路由后恢复"],
     "01-67/03-68"),
    ("MQTT", "FORCE-EXIT", "MQTT 集群节点强制退出",
     "3 节点 EMQX",
     "kill -9 1 node",
     ["剩余节点接管会话","cleanSession=false 客户端重连后恢复订阅","QoS1/2 未确认消息补发"],
     "01-64/03-68"),

    # 网络分区/脑裂
    ("KAFKA", "NETPART", "Kafka 最小 ISR 失守分区不可用",
     "3 broker，topic RF=3，acks=all，min.insync.replicas=2",
     "网络分区隔离 leader 与 1 follower",
     ["满足 acks=all 的 ISR 不足，分区停止写入","消费者仍可读至旧 HW","unclean.leader.election.enable=false 防止非 ISR 晋升"],
     "01-61 §1.61.2"),
    ("NATS", "NETPART", "NATS 集群无脑裂声明",
     "3 节点 JetStream R3",
     "分区使 1 节点孤立",
     ["孤立节点无法构成 quorum，停止 JetStream 写","多数派侧继续服务","恢复后通过 RAFT 日志合并"],
     "01-66"),
    ("RABBITMQ", "NETPART", "RabbitMQ pause_minority 行为",
     "3 节点集群，cluster_partition_handling=pause_minority",
     "分区产生 1 vs 2",
     ["少数派（1 节点）暂停应用","多数派继续服务","恢复后 minority 恢复并同步"],
     "01-65/03-68"),
    ("PULSAR", "NETPART", "Pulsar Metadata Store 分区",
     "3 节点 ZooKeeper/Oxia",
     "隔离 1 节点",
     ["多数派继续提供元数据服务","少数派不可写，broker 连接可能失败","ledger 元数据无法更新导致新 ledger 创建失败"],
     "01-62 §1.62.7"),
    ("REDIS", "NETPART", "Redis 哨兵 quorum 与分区",
     "3 sentinel + 1 master + 2 replica",
     "分区隔离 master 与多数 sentinel",
     ["只有 ≥quorum 的 sentinel 才能发起 failover"," minority sentinel 不会误晋升 replica","避免双主"],
     "01-67/03-68"),
    ("ROCKETMQ", "NETPART", "RocketMQ namesrv 分区",
     "2 namesrv 集群（无共识）",
     "隔离 1 namesrv",
     ["broker 向存活 namesrv 注册","producer 仍可从任一 namesrv 拉取路由","namesrv 无状态，恢复后自动同步"],
     "01-67/03-68"),
    ("MQTT", "NETPART", "MQTT 集群桥接分区",
     "2 节点 EMQX 桥接集群",
     "断开节点间集群链路",
     ["各分区独立服务（可能产生消息分叉）","桥接/集群策略决定是否允许 minority 写","恢复后需按策略合并会话"],
     "01-64/03-68"),

    # 恢复合并
    ("KAFKA", "HEAL", "Kafka 分区愈合与 unclean.leader 风险",
     "分区隔离后恢复网络",
     "观察 leader epoch 与数据收敛",
     ["ISR 重新扩展","Leader Epoch 单调递增，避免日志分歧","unclean.leader.election.enable=true 场景下可能出现数据丢失"],
     "01-61 §1.61.2/1.61.3"),
    ("NATS", "HEAL", "NATS 分区愈合后流状态收敛",
     "JetStream R3 分区后愈合",
     "检查 stream info 与 consumer sequence",
     ["RAFT 日志合并，stream leader 唯一","消息顺序一致","无重复 sequence"],
     "01-66"),
    ("RABBITMQ", "HEAL", "RabbitMQ 分区愈合后镜像同步",
     "镜像队列经历 pause_minority 后恢复",
     "重新启用应用并同步",
     ["mirror 与 master 同步完成","无未同步消息暴露给消费者","ha-sync-mode=automatic 时自动同步"],
     "01-65/03-68"),
    ("PULSAR", "HEAL", "Pulsar 分区愈合后 ledger 复制收敛",
     "bookie 分区恢复",
     "检查 under-replicated ledgers",
     ["Auditor/AutoRecovery 补齐副本","underReplicatedLedgers 降至 0","读写恢复正常"],
     "01-62 §1.62.7"),
    ("REDIS", "HEAL", "Redis 旧主降为副本冲突解决",
     "failover 后旧 master 重新加入集群",
     "观察 configEpoch 与 slot 归属",
     ["旧 master 以 replica 身份加入","其数据被新 master 覆盖","cluster 使用 configEpoch 解决冲突"],
     "01-67/03-68"),
    ("ROCKETMQ", "HEAL", "RocketMQ 分区愈合后路由收敛",
     "broker 与 namesrv 分区恢复",
     "producer 拉取最新路由",
     ["broker 重新注册到 namesrv","producer 路由缓存刷新","无长期消息路由黑洞"],
     "01-67/03-68"),
    ("MQTT", "HEAL", "MQTT 集群分区愈合后会话收敛",
     "2 节点集群分区后愈合",
     "cleanSession=false 客户端重连",
     ["会话元数据按集群策略合并或保留 majority","未确认 QoS1/2 消息不重复/不丢失","共享订阅状态一致"],
     "01-64/03-68"),

    # 扩展：集群共识与再分配
    ("KAFKA", "KRAFT-QUORUM", "Kafka KRaft controller quorum 分区",
     "3 controller KRaft quorum",
     "网络分区隔离 1 controller",
     ["多数派继续提供元数据写","少数派 controller 停止处理变更","broker 元数据缓存仍可读，直至 reconnect 到 active quorum"],
     "01-61 §1.61.4"),
    ("NATS", "SUPERCLUSTER", "NATS Supercluster 分区行为",
     "2 区域各 3 节点 JetStream",
     "断开 gateways",
     ["每个区域独立选举 stream leader","区域间消息复制中断","恢复后 gateway 重建并补全跨域副本"],
     "01-66"),
    ("PULSAR", "BUNDLE-SPLIT", "Pulsar Bundle 分裂与负载均衡",
     "namespace 单个 bundle 高负载",
     "触发 bundle split 或手动 unload",
     ["bundle 分裂为两个 hash 区间","原 owner 断开客户端连接","新 topic 按 hash 落入新 bundle，ownership 重新竞争"],
     "01-62 §1.62.1/1.62.6"),
    ("RABBITMQ", "QUORUM-LEADER", "RabbitMQ Quorum Queue leader 选举",
     "3 节点 quorum queue",
     "kill leader node",
     ["剩余 follower 基于 Raft 选出新 leader","已 confirm 消息可继续消费","旧 leader 恢复后以 follower 加入并同步"],
     "01-65"),
    ("REDIS", "REPLACE", "Redis Cluster 节点替换",
     "3 主 3 从，标记一主为 fail",
     "CLUSTER FORGET 旧节点并加入新节点作为 replica",
     ["新节点被分配为某主 replica","数据从 master 同步","cluster 最终状态稳定，slots 无遗漏"],
     "01-67/03-68"),
]


def slug(s):
    return s.lower().replace(" ", "-").replace("/", "-")


def write_cases(cases, domain):
    made = 0
    rows = []
    for sys_, code, name, given, when, thens, src in cases:
        cid = f"TC-{domain}-{sys_}-{code}-01"
        d = os.path.join(BASE, "cases", domain.lower(), sys_.lower(), slug(code))
        os.makedirs(d, exist_ok=True)
        body = f"""# {cid}：{name}

> **维度**：系统={sys_} | 域={domain} | 断言面：CLI/admin/metrics（语言无关）
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
bash Testing/08-运维行为测试/cases/{domain.lower()}/{sys_.lower()}/{slug(code)}/{cid}.sh   # 计划打印（挂账）
```

## 关联
- {src}；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
"""
        open(os.path.join(d, cid + ".md"), "w", encoding="utf-8", newline="\n").write(body)
        rows.append(f"{cid}\t{domain}\t-\tE2\t08-运维行为测试\tpending")
        made += 1
    return made, rows


def main():
    pst_made, pst_rows = write_cases(PST_CASES, "PST")
    clu_made, clu_rows = write_cases(CLU_CASES, "CLU")
    with open(REG, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(pst_rows + clu_rows) + "\n")
    print(f"pst_cases={pst_made}")
    print(f"clu_cases={clu_made}")


if __name__ == "__main__":
    main()
