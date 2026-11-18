#!/usr/bin/env python3
# 08-运维行为测试 SCL（弹性伸缩）+ ALT（报警自愈）用例生成器
# 产物：cases/scl/* / cases/alt/* + registry 追加 SCL/ALT 域
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "08-运维行为测试")

# KB[(domain, subcat, sys)] = (name, given, when, [then...], doc_refs)
# domain ∈ {SCL,ALT}; subcat 为二级目录; sys 为系统/规则短码
KB = {
# === SCL PARTSCALE 分区伸缩 ===
("SCL","PARTSCALE","KAFKA-01"):("Kafka 运行中加分区期间生产不中断","3 broker / 3 partition topic / acks=all 持续生产","kafka-topics --alter --partitions 6",["生产端无 RecordBatch Expired 异常","__consumer_offsets 重平衡在 max.poll.interval 内完成","新增分区 leader 分布可观测（kafka-log-dirs）","键映射保持：同一 key 仍路由到同一分区（旧 key 范围不变）"],"01-61,02-49,08-运维行为测试"),
("SCL","PARTSCALE","KAFKA-02"):("Kafka 加分区后现有消息键映射保持","topic 已有 10 万条 keyed 消息","执行 --alter --partitions 6 后按 key 消费",["消费顺序：旧 partition 内 key 顺序不变","新分区从 offset 0 开始","无消息重复或遗漏"],"01-61,01-72"),
("SCL","PARTSCALE","KAFKA-03"):("Kafka 分区重分配期间吞吐影响","topic 6 分区 / 生产消费压测","kafka-reassign-partitions --execute --throttle",["throttle 字节率生效（指标 kafka_server_replicamanager_replication_throttled_rate）","生产吞吐下降≤30%【估算】","重分配完成后 URP=0","数据校验和完整"],"01-61,03-67"),
("SCL","PARTSCALE","PULSAR-01"):("Pulsar bundle split 期间生产不中断","namespace 高流量 topic","pulsar-admin namespaces split-bundle",["split 期间 broker 不丢写","bundle 边界可观测（topic 归属）","加载到新 broker 后 backlog 一致"],"01-62,02-49"),
("SCL","PARTSCALE","PULSAR-02"):("Pulsar bundle unload 负载再平衡","broker 负载不均","pulsar-admin namespaces unload",["unload 窗口≤秒级","客户端重连到新 broker 成功","topic 统计无跳跃"],"01-62"),
("SCL","PARTSCALE","PULSAR-03"):("Pulsar split + unload 组合流量下正确性","持续生产+消费","split 后立即 unload",["无重复消费（dedup 保证）","无消息丢失","bundle 元数据一致性"],"01-62"),
("SCL","PARTSCALE","ROCKETMQ-01"):("RocketMQ topic 读写队列扩容","broker 配置写队列数变更","更新 perm + 队列数",["新消息路由到新队列","消费进度按队列隔离","namesrv 路由同步"],"01-61,03-67"),
("SCL","PARTSCALE","NATS-01"):("NATS JetStream stream 分区（subject 映射）扩展","R1 stream / 持续发布","更新 stream subjects",["新 subject 消息进入同一 stream","consumer filter 即时生效","sequence 连续"],"01-66"),

# === SCL NODESCALE 节点伸缩 ===
("SCL","NODESCALE","KAFKA-01"):("Kafka broker 扩容后分区迁移可观测","3 broker / 6 partition","启动第 4 broker",["分区副本开始迁移（kafka-reassign-partitions --verify）","UnderReplicatedPartitions 峰值可控","迁移进度百分比可计算"],"01-61,02-49"),
("SCL","NODESCALE","KAFKA-02"):("Kafka 新 broker 接管分区迁移进度指标","持续监控 JMX","观察 ReplicaFetcherManager",["kafka_server_replicamanager_underreplicatedpartitions 收敛","bytes in/out 均衡度改善","无 leader 长时间悬挂"],"01-61"),
("SCL","NODESCALE","KAFKA-03"):("Kafka 新 broker 成为 preferred leader","auto.leader.rebalance.enable=true","等待 preferred leader 选举",["preferred leader 比例≥90%【估算】","生产切换无异常","metadata 更新全客户端可见"],"01-61"),
("SCL","NODESCALE","PULSAR-01"):("Pulsar bookie 扩容后 ledger 再分布","3 bookie / 持续写入","启动第 4 bookie",["新 bookie 开始接收新 ledger","auditor 触发 rereplication","磁盘使用率差距缩小"],"01-62,03-67"),
("SCL","NODESCALE","PULSAR-02"):("Pulsar bookie 扩容读路径均衡","消费冷数据","rereplication 完成后读",["读请求分散到新 bookie","pulsar_storage_read_rate 均衡","延迟无长尾"],"01-62"),
("SCL","NODESCALE","NATS-01"):("NATS 集群加节点路由收敛","3 node cluster / 持续 sub/pub","启动第 4 server",["server 加入 cluster 成功（/routez）","interest 同步完成","客户端连接可路由到新节点"],"01-66,03-67"),
("SCL","NODESCALE","NATS-02"):("NATS supercluster 网关节点加入","supercluster 两域","新网关上线",["gateway 连接建立（/gatewayz）","跨域主题传播正常","无消息隔离"],"01-66"),
("SCL","NODESCALE","RABBITMQ-01"):("RabbitMQ 集群节点加入与镜像队列再平衡","3 node cluster / HA queue","新节点加入",["新节点出现在 cluster_status","镜像队列副本重新分布","policy ha-all 生效"],"03-67,01-61"),
("SCL","NODESCALE","ROCKETMQ-01"):("RocketMQ broker 注册 namesrv 收敛","持续生产","新 broker 启动",["namesrv 路由表新增 broker","producer 更新路由","消费无中断"],"01-61"),
("SCL","NODESCALE","REDIS-01"):("Redis Cluster 加节点 resharding","3 master / 持续写入","redis-cli --cluster add-node + reshard",["slot 迁移进度可观测（cluster nodes）","keys 迁移后一致","客户端 moved/ask 响应正确"],"01-67,03-67"),

# === SCL CONSSCALE 消费者伸缩 ===
("SCL","CONSSCALE","KAFKA-01"):("Kafka 消费组 1→3 成员变化重平衡时长","topic 6 partition / 1 consumer","启动到 3 consumers",["重平衡完成时间≤30s【估算】","partition 分配均衡","消费继续"],"01-75,08-运维行为测试"),
("SCL","CONSSCALE","KAFKA-02"):("Kafka 消费组 3→1 成员变化重平衡时长","3 consumers 稳定消费","停掉 2 consumers",["重平衡完成时间≤30s【估算】","剩余 consumer 接管全部分区","无重复消费（stable）"],"01-75"),
("SCL","CONSSCALE","KAFKA-03"):("Kafka 重平衡期间生产不中断","持续 producer","消费组 1→3→1",["producer send() 无超时","已 ack 消息不丢","重平衡次数=2"],"01-75,TC-OPS-KAFKA-REBALPRODUCE-01"),
("SCL","CONSSCALE","KAFKA-04"):("Kafka static membership 减少重平衡震荡","配置 group.instance.id","consumer 重启（member 不变）",["重平衡不触发（静态成员）","消费继续","再加入时 offset 恢复"],"01-75"),
("SCL","CONSSCALE","RABBITMQ-01"):("RabbitMQ 消费者增加时发布不中断","队列有 1 consumer","consumer 扩到 3",["publisher 无阻塞","round-robin 分发即时生效","队列长度下降"],"03-68"),
("SCL","CONSSCALE","PULSAR-01"):("Pulsar 消费者增加时生产不中断","1 consumer subscription","consumer 扩到 3",["无 ack 超时","key_shared 下同一 key 仍到同一 consumer","吞吐上升"],"01-62"),
("SCL","CONSSCALE","NATS-01"):("NATS queue group 1→3→1 分发重排","queue subject / 1 subscriber","queue group 扩缩",["消息分发即时重排无中断","无重复投递（exactly-once queue）","sub 退出时消息不丢"],"01-66,03-68"),
("SCL","CONSSCALE","MQTT-01"):("MQTT 共享订阅组 1→3→1","$share/group/topic / 1 subscriber","共享订阅成员扩缩",["$share 分发重排无中断","QoS1/2 消息按订阅者唯一交付","会话保持正确"],"01-64"),

# === SCL AUTOSCALE 自动伸缩 ===
("SCL","AUTOSCALE","KAFKA-01"):("KEDA Kafka lag 触发扩容","ScaledObject pollingInterval=30 / lagThreshold=1000","注入 lag 斜坡",["HPA 目标副本数从 2→N","KEDA operator 日志显示 ScaleDeployment","消费速率上升后 lag 下降"],"02-49,topics/config-templates/keda-scaledobject-kafka.yaml"),
("SCL","AUTOSCALE","KAFKA-02"):("KEDA 缩容冷却期生效","lag 恢复正常后","等待 cooldownPeriod=300s",["副本数不立即下降","冷却期内消费完成","最终回到 minReplicaCount"],"02-49,04-07"),
("SCL","AUTOSCALE","KAFKA-03"):("KEDA maxReplicaCount 边界 ≤ 分区数","topic partition=6","lag 无限上涨",["副本数≤6（allowIdleConsumers=false）","KEDA 日志提示 idle consumer 禁止","无空转 consumer"],"02-49"),
("SCL","AUTOSCALE","KAFKA-04"):("HPA CPU 与 KEDA lag 双控制器不冲突","HPA 按 CPU / KEDA 按 lag","并发压力",["两控制器作用不同维度","无同时反向动作","副本数单调收敛"],"04-07"),
("SCL","AUTOSCALE","KAFKA-05"):("KEDA scale to zero 空闲消费者","idleReplicaCount=0 / 无 lag","等待 idle",["副本数降到 0","新 lag 到来后恢复","恢复时间可接受"],"02-49"),
("SCL","AUTOSCALE","NATS-01"):("KEDA NATS JetStream pending 触发扩容","nats scaler / pendingThreshold","注入 pending",["副本数按 pending 增加","JetStream consumer ack 跟上","pending 回落"],"02-49"),
("SCL","AUTOSCALE","RABBITMQ-01"):("KEDA RabbitMQ queue length 触发扩容","rabbitmq scaler / queueName / lengthThreshold","队列填充",["副本数增加","队列长度下降","无死信风暴"],"02-49"),
("SCL","AUTOSCALE","PULSAR-01"):("KEDA Pulsar backlog 触发扩容","pulsar scaler / admin url / threshold","backlog 增长",["副本数增加","subscription backlog 下降","无重复消费"],"02-49"),
("SCL","AUTOSCALE","MQTT-01"):("MQTT 自定义 lag 指标触发伸缩","mosquitto exporter / custom metric","设备洪峰",["自定义 metrics 被 HPA 读取","副本数变化","连接数均衡"],"03-63"),
("SCL","AUTOSCALE","REDIS-01"):("Redis Stream XPENDING 触发扩容","自定义 exporter / pending count","pending 增长",["consumer 扩容","XPENDING 下降","消息处理不超时"],"01-66"),

# === SCL OSCPREVENT 振荡防控（04-07 四陷阱） ===
("SCL","OSCPREVENT","DEADBAND-01"):("死区：lag 抖动 ±20% 内 KEDA 不动作","lagThreshold=1000 / lag 在 900~1100 波动","持续 5 分钟",["副本数不变","控制动作次数=0","抖动被死区吸收"],"04-07"),
("SCL","OSCPREVENT","DEADBAND-02"):("Prometheus deadband 抑制规则告警抖动","告警规则 for=1m / 合成指标在阈值附近抖动","观察 alertmanager",["告警只触发一次","恢复后只解除一次","无 flapping 通知"],"04-07,03-63"),
("SCL","OSCPREVENT","MULTICTL-01"):("多控制器冲突：HPA 与 KEDA 同指标 lag 同时动作","HPA 按 lag / KEDA 也按 lag","lag 上升",["观察到副本数抖动或超调","记录冲突","改为单指标单控制器后稳定"],"04-07"),
("SCL","OSCPREVENT","MULTICTL-02"):("分维度控制器稳定：CPU vs lag 双维度","HPA CPU / KEDA lag 不同阈值","复合压力",["两控制器各自按维度动作","无振荡","最终 SLO 恢复"],"04-07"),
("SCL","OSCPREVENT","INTEGRAL-01"):("积分饱和：KEDA 长期误差 I 项限幅","模拟一周积压后 I 项巨大","启用积分限幅",["扩容幅度被限制","无一次性扩 10 倍","系统稳定"],"04-07"),
("SCL","OSCPREVENT","INTEGRAL-02"):("分段重置：backlog 周级别回落后 I 项清零","backlog 从高位回落","触发 anti-windup 重置",["I 项归零","缩容按保守策略执行","无超调"],"04-07"),
("SCL","OSCPREVENT","COLDSTART-01"):("冷启动雪崩：批量扩容同时拉全量快照","一次性扩容 10 副本","每个副本启动即全量恢复",["消费端出现请求风暴/超时","后端存储压力峰值","记录雪崩"],"04-07"),
("SCL","OSCPREVENT","COLDSTART-02"):("分批滚动预热防止雪崩","分 3 批扩容 / 每批预热","lag 逐步下降",["每批启动后预热完成再下一批","无存储请求风暴","总 RTO 可接受"],"04-07"),
("SCL","OSCPREVENT","DELAY-01"):("延迟振荡：采样周期 < 执行器响应时间","pollingInterval=15s / 扩容生效 60s","持续波动负载",["观察到越扩越乱","调整 pollingInterval≥90s 后稳定","04-07 定理"],"04-07"),

# === ALT ALERTRULE 告警规则正确性 ===
("ALT","ALERTRULE","KAFKA-OFFLINE"):("KafkaOfflinePartitions 触发与解除","合成 kafka_controller_offlinepartitionscount=1","持续 1m 后清零",["1m 后告警 firing","清零后 1m 内告警 resolved","runbook 链接可访问"],"topics/config-templates/prometheus-alert-rules.yml,03-63"),
("ALT","ALERTRULE","KAFKA-URP"):("KafkaUnderReplicated 触发与解除","合成 underreplicatedpartitions=2","持续 10m 后清零",["10m 后告警 firing","清零后恢复","severity=p1"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","KAFKA-LAG"):("KafkaConsumerLagHigh 触发与解除","合成 kafka_consumergroup_lag=150000","持续 15m 后降 0",["15m 后告警 firing","lag 降 0 后 resolved","按 consumergroup/topic 聚合"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","KAFKA-DISK"):("KafkaDiskPressure 触发与解除","合成磁盘使用率 0.8","持续 10m 后 0.5",["10m 后告警 firing","释放空间后 resolved","mountpoint=/var/lib/kafka"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","RMQ-NODE"):("RabbitMQNodeDown 触发与解除","合成 rabbitmq_up=0","持续 2m 后 1",["2m 后告警 firing","恢复后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","RMQ-BACKLOG"):("RabbitMQQueueBacklog 触发与解除","合成 queue_messages_ready=60000","持续 15m 后 0",["15m 后告警 firing","消费后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","NATS-DOWN"):("NATSServerDown 触发与解除","合成 gnatsd_varz_up=0","持续 2m 后 1",["2m 后告警 firing","恢复后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","NATS-PENDING"):("NATSJetStreamConsumerStalled 触发与解除","合成 nats_jetstream_consumer_num_pending=15000","持续 15m 后 0",["15m 后告警 firing","消费后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","REDIS-MEM"):("RedisMemoryHigh 触发与解除","合成 redis_memory_used/max=0.85","持续 10m 后 0.5",["10m 后告警 firing","释放后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","PULSAR-BACKLOG"):("PulsarBacklogGrowth 触发与解除","合成 pulsar_subscription_back_log=150000","持续 15m 后 0",["15m 后告警 firing","消费后 resolved"],"topics/config-templates/prometheus-alert-rules.yml"),
("ALT","ALERTRULE","INHIBIT"):("告警风暴 inhibit 去重","同时触发 KafkaOfflinePartitions + KafkaUnderReplicated","配置 inhibit 规则：p0 抑制 p1",["只收到 p0 通知","p1 被抑制不重复通知","inhibit 日志可审计"],"topics/config-templates/prometheus-alert-rules.yml,03-63"),
("ALT","ALERTRULE","SILENCE"):("Alertmanager silence 临时屏蔽告警","KafkaConsumerLagHigh 持续 firing","创建 silence matcher",["silence 期间通知停止","silence 过期后通知恢复","silence 元数据可审计"],"03-63"),

# === ALT METRICCHK 指标正确性 ===
("ALT","METRICCHK","KAFKA-LAG"):("Kafka consumergroup lag 指标与实际情况对拍","生产 N 条 / 消费 M 条","对比 kafka_consumergroup_lag 与 实际 offset 差",["指标 lag = 实际未消费数","按 group+topic+partition 聚合正确","JMX exporter 无标签丢失"],"01-61,03-63"),
("ALT","METRICCHK","KAFKA-TPUT"):("Kafka throughput 指标与压测实际对拍","固定速率生产","对比 kafka_server_brokertopicmetrics_messagesinpersec 与 producer 计数",["差值<5%【估算】","topic 维度可下钻","broker 维度求和一致"],"01-61"),
("ALT","METRICCHK","KAFKA-ERR"):("Kafka 错误率指标与客户端异常对拍","注入 RecordTooLarge / 超时","对比 broker error 指标与客户端异常数",["错误码一致","无静默失败","metrics 标签含 error 类型"],"01-61,01-72"),
("ALT","METRICCHK","NATS-VARZ"):("NATS /varz 指标与 nats-server 状态对拍","集群 3 node","对比 /varz connections/memory 与 prometheus gnatsd_varz_*",["connections 数值一致","memory 一致","server_id 标签正确"],"01-66,03-63"),
("ALT","METRICCHK","NATS-PENDING"):("NATS JetStream pending 指标与实际未 ack 对拍","发布 N 条未 ack","对比 nats_jetstream_consumer_num_pending 与实际",["pending = 未 ack 数","consumer+stream 标签正确","ack 后同步归零"],"01-66"),
("ALT","METRICCHK","RMQ-DEPTH"):("RabbitMQ prometheus 插件队列深度对拍","队列有 N 条 ready","对比 rabbitmq_queue_messages_ready 与 rabbitmqctl list_queues",["差值=0","队列标签正确","无镜像重复计数"],"03-63"),
("ALT","METRICCHK","RMQ-RATE"):("RabbitMQ publish rate 指标对拍","固定速率 publish","对比 rabbitmq_channel_messages_published_total 与客户端计数",["差值<5%【估算】","时间窗口对齐"],"03-63"),
("ALT","METRICCHK","PULSAR-BACKLOG"):("Pulsar subscription backlog 指标对拍","生产 N 条未消费","对比 pulsar_subscription_back_log 与实际",["backlog = 未消费数","topic+subscription 标签正确"],"01-62"),
("ALT","METRICCHK","PULSAR-RATE"):("Pulsar broker 吞吐指标对拍","固定速率生产","对比 pulsar_broker_msg_in_rate 与 producer 计数",["差值<5%【估算】","broker 维度可下钻"],"01-62"),
("ALT","METRICCHK","REDIS-LAG"):("Redis Stream consumer lag 指标对拍","XADD N 条 / 未 XREADGROUP","对比 XPENDING 长度与自定义 exporter",["lag = pending 条目数","consumer group 标签正确"],"01-66"),
("ALT","METRICCHK","REDIS-MEM"):("Redis 内存指标与 INFO memory 对拍","写入数据集","对比 redis_memory_used_bytes 与 INFO memory used",["差值=0","maxmemory 边界一致"],"03-63"),
("ALT","METRICCHK","MQTT-BRIDGE"):("MQTT 桥接指标与 mosquitto 状态对拍","桥接发布 N 条","对比 bridge metrics 与实际",["桥接连接状态一致","消息计数一致"],"01-64,03-63"),

# === ALT SELFHEAL 自愈闭环 E2E ===
("ALT","SELFHEAL","KAFKA"):("Kafka kill 消费者 → KEDA 重启恢复","Deployment consumer / KEDA ScaledObject","kill 全部 consumer pods",["consumer pods 数降到 0 后 KEDA 触发恢复","lag 不持续恶化","服务恢复≤2 min【估算】"],"02-49,03-63,04-07"),
("ALT","SELFHEAL","NATS"):("NATS consumer crash → KEDA 重启恢复","JetStream consumer Deployment / KEDA nats scaler","删除 consumer pods",["pending 上升触发 scaler","pod 重建后消费恢复","sequence 无跳跃"],"02-49,01-66"),
("ALT","SELFHEAL","RABBITMQ"):("RabbitMQ node OOM → 自动重启恢复","K8s pod / livenessProbe","注入 OOM",["pod 重启","队列镜像重新选举","publisher 阻塞解除"],"03-63"),
("ALT","SELFHEAL","PULSAR"):("Pulsar broker kill → K8s 重启恢复","broker StatefulSet","删除 broker-1 pod",["新 pod 启动","topic 重新指派","无写入中断"],"01-62,03-63"),
("ALT","SELFHEAL","REDIS"):("Redis master failover → sentinel 切主恢复","Redis Sentinel / 1 master 2 replica","kill master",["sentinel 选举新主","客户端重定向成功","数据一致性符合配置"],"01-67,03-63"),
("ALT","SELFHEAL","ROCKETMQ"):("RocketMQ broker kill → namesrv 路由自愈","producer 缓存路由 / broker 主从","kill broker",["namesrv 路由移除死 broker","producer 更新路由","主从切换（若配置）"],"01-61"),
("ALT","SELFHEAL","MQTT"):("MQTT broker kill → 持久会话恢复","cleanSession=false / 持久会话","kill broker",["客户端自动重连","持久会话恢复","QoS1/2 消息补传"],"01-64,03-68"),
("ALT","SELFHEAL","GENERIC"):("通用控制回路 E2E：故障→检测→动作→验证","prometheus + alertmanager + webhook + KEDA","kill consumer 并等待规则触发",["告警 firing","webhook 收到通知","KEDA 动作恢复","TEST-16 三模板填写完毕"],"04-07,Testing/05-体系与机制/TEST-16-hermes执行规划与问题闭环.md"),

# === ALT NOTIFYCHAIN 通知链 ===
("ALT","NOTIFYCHAIN","WEBHOOK"):("告警 → webhook mock 接收端断言","alertmanager webhook receiver 指向 mock","触发任意告警",["mock 收到 JSON payload","alert labels 完整","resolved 通知也收到"],"03-63"),
("ALT","NOTIFYCHAIN","EMAIL"):("告警 → mock SMTP 邮件断言","alertmanager email receiver 指向 mailhog","触发告警",["mailhog 收到邮件","subject 含告警名","恢复邮件收到"],"03-63"),
("ALT","NOTIFYCHAIN","DEDUP"):("告警分组去重：同类告警合并通知","同 topic 多 partition 同时触发 lag 告警","group_by=[topic]",["只收到 1 条通知","groupKey 正确","silence 后不再重复"],"03-63"),
}

# 子分类中文名映射（用例标题）
SUBCAT_NAME = {
"PARTSCALE":"分区伸缩","NODESCALE":"节点伸缩","CONSSCALE":"消费者伸缩",
"AUTOSCALE":"自动伸缩","OSCPREVENT":"振荡防控",
"ALERTRULE":"告警规则正确性","METRICCHK":"指标正确性",
"SELFHEAL":"自愈闭环 E2E","NOTIFYCHAIN":"通知链",
}

# 每个用例关联的 TEST-16 三模板标记
TEST16_REF = "Testing/05-体系与机制/TEST-16-hermes执行规划与问题闭环.md §T.16.3 三模板"

def render(domain, subcat, code, name, given, when, thens, refs):
    # code 中已含场景序号（如 KAFKA-01/DEADBAND-01），ID 只保留一段 -01
    base_code = code[:-3] if code.endswith("-01") else code
    cid = f"TC-{domain}-{subcat}-{base_code}-01"
    d = os.path.join(BASE, "cases", domain.lower(), subcat.lower())
    os.makedirs(d, exist_ok=True)
    subname = SUBCAT_NAME[subcat]
    body = f"""# {cid}：{subname} — {name}

> **维度**：domain={domain} | subcat={subcat} | code={code} | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：{refs}
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- {given}

## When
- {when}

## Then
"""
    body += "".join(f"- {t}\n" for t in thens)
    if domain == "ALT" and subcat in ("SELFHEAL", "NOTIFYCHAIN"):
        body += f"""
## 问题闭环（TEST-16 三模板）
- 问题报告单：记录故障注入时间、检测延迟、动作触发时间（模板 A）
- 修复/复盘单：P0/P1 必填，回流至 `Testing/05-体系与机制/cases/YYYY-MM-<slug>.md`（模板 C）
- registry 状态流转：pending → verified / quarantined（按 TEST-13 漂移机制）
> 模板来源：{TEST16_REF}
"""
    body += f"""
## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/{domain.lower()}/{subcat.lower()}/{cid}.sh   # 计划打印（挂账）
```

## 关联
- {refs}；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
"""
    open(os.path.join(d, cid + ".md"), "w", encoding="utf-8", newline="\n").write(body)
    return cid

made, reg_rows = 0, []
for (domain, subcat, code), (name, given, when, thens, refs) in KB.items():
    cid = render(domain, subcat, code, name, given, when, thens, refs)
    reg_rows.append(f"{cid}\t{domain}\t-\tE2\t{refs}\tpending")
    made += 1

with open(os.path.join(ROOT, "topics", "scripts", "test-registry.tsv"), "a", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(reg_rows) + "\n")
print(f"scl_alt_cases={made}  (SCL≈45 / ALT≈35)")
