#!/usr/bin/env python3
# 08-运维行为测试 用例生成器（批次122）：catalog 适用矩阵 × KB → GWT 用例 + OPS 域注册
import os, csv

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "08-运维行为测试")
CAT = os.path.join(BASE, "catalog", "ops-behavior.tsv")

# KB[(sys, beh)] = (given, when, [then...], src)；未命中用 category 默认模板
KB = {
("KAFKA","DISKFULL"):("单 broker log.dirs 注入填充至阈值","继续生产",["日志出现 not accepting new data（03-68）","清理后自动恢复写（无重启）","已落段校验和完整"],"03-68 故障行为"),
("KAFKA","DISKSLOW"):("iostat 注入读延迟 100ms+","生产+消费并发",["p99 上升可观测","ISR 收缩行为符合 01-61 推演表","慢盘副本被踢出后恢复"],"01-61 §1.61.7/03-68"),
("KAFKA","NETPART"):("iptables 隔离 leader 与 2 副本","持续生产 acks=all",["分区不可用窗口=min.insync 失守","恢复后 leader epoch 递增无数据分歧（Jepsen 边界）"],"03-68/conformance-matrix"),
("KAFKA","BROKERKILL"):("kill -9 leader broker","RTO 计时",["ISR 重选≤30s【估算】","已 ack 消息不丢","metadata 无悬挂分区"],"01-67 故障模式"),
("KAFKA","METALOSS"):("kill KRaft 控制器（单控）","元数据操作",["元数据只读窗口","重启后快照+日志回放一致","__cluster_metadata 校验和"],"01-61 KRaft 节"),
("KAFKA","REPLICALOST"):("pause 一副本 60s","观察 ISR",["ISR 收缩时机符合 replica.lag.time.max.ms","恢复后追赶再入 ISR"],"01-61 复制协议"),
("KAFKA","STARTSEQ"):("compose 起 broker","就绪探针",["控制器选举先于 broker ready","auto.create 生效"],"03-68 启动序列"),
("KAFKA","GRACEFUL"):("SIGTERM 优雅停机","在途生产",["controlled shutdown：leader 迁移完成","无 Unclean leader"],"03-68"),
("KAFKA","FORCEKILL"):("kill -9 + 重启","RTO+日志校验",["log-dump 校验段完整","recovery.point 之后无空洞"],"01-61 §故障推演"),
("KAFKA","ROLLING"):("逐 broker 滚动重启（单节点退化为重启窗口）","消费连续性",["窗口内消费者重平衡完成","无消息丢失"],"03-67 升级路径"),
("KAFKA","MEMWATER"):("堆填充压测","broker 内存曲线",["GC 日志特征符合 03-68 资源模型","无 OOM（ExitOnOutOfMemoryError 前兆可观测）"],"03-68 资源"),
("KAFKA","GCPRESS"):("老年代填充至 80%","生产持续",["停顿频率上升可观测","ZGC/G1 特征符合配置"],"03-68"),
("KAFKA","PAGECACHE"):("echo 3 > drop_caches","冷读消费",["读放大：冷段延迟上升","热段（active segment）不读页缓存"],"01-61"),
("KAFKA","HOTRELOAD"):("动态配置子集（log.retention.ms 等）","kafka-configs --alter",["生效不重启；静态配置拒绝动态修改并提示"],"03-67 配置面"),
("KAFKA","DYNCONFIG"):("逐配置项 alter 测试","回读",["动态域清单与 03-67 画像一致","需重启项正确拒绝"],"03-67"),
("KAFKA","INVALIDCFG"):("注入非法值（num.partitions=0）","启动",["启动失败+可读错误","配置校验先于监听"],"03-68"),
("KAFKA","METARESTORE"):("删除 controller 快照目录","重启",["从最近快照+日志恢复","epoch 单调"],"01-61"),
("KAFKA","LOGREPAIR"):("截断最后段文件 1KB","重启",["坏段隔离+恢复点之前完整","log-dump 可审计"],"01-61"),
("KAFKA","QUOTA"):("生产/消费超 produce/fetch 配额","压测",["throttle 时间可观测（QuotaManager 指标）","超限报错而非静默"],"01-61/03-68"),
("KAFKA","CONNLIMIT"):("批量短连接风暴","连接曲线",["max.connections 生效拒绝+恢复","无句柄泄漏"],"03-68"),
("KAFKA","MSGSIZE"):("发送 max.message.bytes+1 消息","生产",["RecordTooLargeException+错误码","边界值（恰好=上限）通过"],"01-72 大小矩阵"),
("KAFKA","REBALPRODUCE"):("消费组运行中新增成员 3 次","持续生产",["生产不中断","重平衡时长≤max.poll.interval 窗口"],"01-75 陷阱节"),
("KAFKA","CLIENTFLOOD"):("1000 并发 producer","连接指标",["accept 队列行为符合内核参数","broker 无雪崩"],"03-68"),
("KAFKA","RECONNSTORM"):("kill 全部消费者立即恢复","重连曲线",["退避行为符合客户端默认","无重试放大失控（04-03 α 系数观测）"],"04-03/01-66"),
("KAFKA","CLIENTVERS"):("librdkafka 旧版+4.x broker 混连","ApiVersions",["协商降级成功（01-71 版本治理）","KIP-896 floor 拒绝过旧客户端并明示"],"01-71"),
("RABBITMQ","DISKFULL"):("磁盘达到 disk_free_limit","发布",["publisher 阻塞（alarm 行为）","清理后自动解除（03-68）"],"03-68 故障"),
("RABBITMQ","DISKSLOW"):("延迟代理数据目录","持久化队列",["持久化吞吐下降","内存队列受影小（对照）"],"03-68"),
("RABBITMQ","NETPART"):("分区隔离一节点（集群时）","镜像队列",["pause_minority 行为","恢复后同步"],"03-68"),
("RABBITMQ","BROKERKILL"):("kill -9","RTO",["mnesia 恢复","已 confirm 消息不丢"],"03-68"),
("RABBITMQ","METALOSS"):("损坏 definitions 文件","重启",["拒绝启动+错误可读","备份 definitions 恢复一致"],"03-67"),
("RABBITMQ","REPLICALOST"):("集群暂停镜像副本","发布",["镜像降级策略生效","恢复后 catchup"],"03-68"),
("RABBITMQ","STARTSEQ"):("compose 起","就绪",["mnesia 表就绪先于 AMQP listener"],"03-68 启动序列"),
("RABBITMQ","GRACEFUL"):("SIGTERM","在途 confirm",["等待连接关闭窗口","队列镜像重新选主"],"03-68"),
("RABBITMQ","FORCEKILL"):("kill -9+重启","消息校验",["持久化消息存活","事务回滚"],"03-68"),
("RABBITMQ","ROLLING"):("逐节点重启","生产连续",["客户端重连成功","无队列不可用窗口"],"03-67"),
("RABBITMQ","MEMWATER"):("内存逼近 watermark（0.4 默认）","发布",["connection/channel 阻塞行为","流控解除"],"03-68 资源模型"),
("RABBITMQ","GCPRESS"):("Erlang scheduler 饱和压测","长连接",["调度器利用率特征","无 scheduler collapse"],"03-68"),
("RABBITMQ","PAGECACHE"):("-","-","","—"),
("RABBITMQ","HOTRELOAD"):("rabbitmq.conf 修改+reload","生效域",["热生效项对照 03-67","listener 类需重启正确提示"],"03-67"),
("RABBITMQ","DYNCONFIG"):("rabbitmqctl set_parameter","参数回读",["runtime 参数即时生效"],"03-67"),
("RABBITMQ","INVALIDCFG"):("非法 config","启动",["拒绝+行号提示"],"03-68"),
("RABBITMQ","METARESTORE"):("definitions 导出/导入","队列拓扑",["round-trip 一致"],"03-67"),
("RABBITMQ","LOGREPAIR"):("-","-","","—"),
("RABBITMQ","QUOTA"):("per-user/vhost limits","超限",["拒绝+limit 错误"],"03-67"),
("RABBITMQ","CONNLIMIT"):("连接风暴","文件句柄",["backlog 行为+ alarms"],"03-68"),
("RABBITMQ","MSGSIZE"):("超 frame_max/16MiB","发布",["连接断开/拒绝（01-72）","边界通过"],"01-72"),
("RABBITMQ","REBALPRODUCE"):("（队列语义无 rebalance）消费者启停","发布连续",["无发布中断"],"03-68"),
("RABBITMQ","CLIENTFLOOD"):("短连接风暴","accept",["connection churn 可观测"],"03-68"),
("RABBITMQ","RECONNSTORM"):("消费者批量重连","重连曲线",["无重连风暴失控"],"04-03"),
("RABBITMQ","CLIENTVERS"):("AMQP 0-9-1/1.0 客户端混连","协议协商",["1.0 走 5672 插件监听"],"01-42"),
("NATS","DISKFULL"):("JetStream 存储目录填满","发布",["JetStream API 报错（存储错误）","Core 发布不受影响（对照）"],"03-68"),
("NATS","DISKSLOW"):("JetStream 慢盘","持久化",["FS 存储延迟指标上升"],"03-68"),
("NATS","NETPART"):("supercluster 链路分区","路由",["孤立集群独立服务","恢复后兴趣同步"],"03-68"),
("NATS","BROKERKILL"):("kill -9","RTO",["Core 无状态恢复快","JetStream 流恢复（RTO 计时）"],"01-67"),
("NATS","METALOSS"):("JetStream 元数据损坏","重启",["流重建+sequence 一致"],"03-67"),
("NATS","REPLICALOST"):("JetStream R3 流停一副本","读写",["R1 降级仍读写","恢复后 re-elect"],"01-66"),
("NATS","STARTSEQ"):("compose 起","监听",["客户端重连成功"],"03-68"),
("NATS","GRACEFUL"):("SIGTERM","lame duck 窗口",[" Drain 完成","无消息丢失"],"03-68"),
("NATS","FORCEKILL"):("kill -9+重启","内存态",["Core 消息丢失声明（反向确认 01-67）","JetStream 持久数据完整"],"01-67"),
("NATS","ROLLING"):("逐节点重启（集群）","路由",["客户端无感"],"03-67"),
("NATS","MEMWATER"):("大 payload 洪峰","slow consumer",["slow consumer 踢出行为（03-68）"],"03-68"),
("NATS","GCPRESS"):("-","-","","—"),
("NATS","PAGECACHE"):("-","-","","—"),
("NATS","HOTRELOAD"):("nats-server -sl reload","配置热载",["生效域对照 03-67（账户/权限热载）"],"03-67"),
("NATS","DYNCONFIG"):("（无动态配置域）","—",["反向用例：仅 reload"],"03-67"),
("NATS","INVALIDCFG"):("非法 conf","启动",["校验拒绝+行号"],"03-68"),
("NATS","METARESTORE"):("JetStream 目录备份恢复","流状态",["消费序列一致"],"03-67"),
("NATS","LOGREPAIR"):("-","-","","—"),
("NATS","QUOTA"):("JetStream limits（maxBytes/maxMsgs）","超限",["拒绝+limit 错误"],"01-66"),
("NATS","CONNLIMIT"):("连接风暴","FD",["max_connections 拒绝"],"03-68"),
("NATS","MSGSIZE"):("超 max_payload=1MiB（01-72）","发布",["Maximum Payload Exceeded","边界通过"],"01-72"),
("NATS","REBALPRODUCE"):("queue group 成员启停","发布连续",["分发即时重排无中断"],"03-68"),
("NATS","CLIENTFLOOD"):("短连接风暴","accept",["FD/路由表压力"],"03-68"),
("NATS","RECONNSTORM"):("客户端批量重连","曲线",["server 无雪崩"],"04-03"),
("NATS","CLIENTVERS"):("-","-","","—"),
("PULSAR","DISKFULL"):("bookie 磁盘满","写入",["ledger 写失败+写入降级","ledger 恢复"],"01-62/03-68"),
("PULSAR","DISKSLOW"):("bookie 慢盘","读写路径",["读降级到其它副本（01-62 读写路径）"],"01-62"),
("PULSAR","NETPART"):("隔离 bookie 组","读写",["ensemble 重选","恢复后 re-replicate"],"01-62"),
("PULSAR","BROKERKILL"):("kill broker","RTO",["topic 重指派","无状态 broker 恢复快"],"01-62"),
("PULSAR","METALOSS"):("ZooKeeper/Oxia 不可用","元数据",["元数据操作失败可见","恢复后一致（Oxia Raft 组）"],"01-62"),
("PULSAR","REPLICALOST"):("停一 bookie","ledger",["写入 ensemble 替换","恢复后 rereplication"],"01-62"),
("PULSAR","STARTSEQ"):("compose 分层起","就绪",["bookie 先于 broker 就绪"],"03-68"),
("PULSAR","GRACEFUL"):("broker drain","在途请求",["优雅卸载完成"],"03-68"),
("PULSAR","FORCEKILL"):("kill -9 bookie","ledger 校验",["恢复后 entry 校验和通过"],"01-62"),
("PULSAR","ROLLING"):("逐 bookie 滚动","写入连续",["无写入中断（01-62 运维窗口）"],"01-62"),
("PULSAR","MEMWATER"):("堆压测","GC",["停顿特征"],"03-68"),
("PULSAR","GCPRESS"):("JVM 填充","停顿",["ZGC/G1 特征"],"03-68"),
("PULSAR","PAGECACHE"):("drop_caches","读路径",["读放大+ledger 缓存命中降"],"01-62"),
("PULSAR","HOTRELOAD"):("动态配置 alter","生效域",["负载均衡器动态生效"],"03-67"),
("PULSAR","DYNCONFIG"):("动态配置域核对","回读",["对照 03-67 画像"],"03-67"),
("PULSAR","INVALIDCFG"):("非法 broker.conf","启动",["拒绝+提示"],"03-68"),
("PULSAR","METARESTORE"):("Oxia 快照恢复","元数据",["namespace 拓扑恢复一致"],"01-62"),
("PULSAR","LOGREPAIR"):("bookie entry 校验和损坏","读取",["坏 entry 隔离+副本读取"],"01-62"),
("PULSAR","QUOTA"):("资源组限速","压测",["throttle 可观测"],"03-68"),
("PULSAR","CONNLIMIT"):("连接风暴","FD",["拒绝+恢复"],"03-68"),
("PULSAR","MSGSIZE"):("超 maxMessageSize=5MiB（01-72）","生产",["拒绝+错误码"],"01-72"),
("PULSAR","REBALPRODUCE"):("消费者订阅变更","生产连续",["无中断"],"03-68"),
("PULSAR","CLIENTFLOOD"):("短连接","accept",["行为可观测"],"03-68"),
("PULSAR","RECONNSTORM"):("重连风暴","曲线",["无失控"],"04-03"),
("PULSAR","CLIENTVERS"):("-","-","","—"),
("ROCKETMQ","DISKFULL"):("commitlog 磁盘满","写入",["刷盘失败行为","清理恢复"],"【论证】03-68"),
("ROCKETMQ","DISKSLOW"):("慢盘","commitlog",["写入延迟上升"],"【论证】"),
("ROCKETMQ","NETPART"):("隔离 broker 组","路由",["namesrv 路由冻结","恢复收敛"],"【论证】"),
("ROCKETMQ","BROKERKILL"):("kill broker","RTO",["主从切换（若配）"],"【论证】"),
("ROCKETMQ","METALOSS"):("kill namesrv","路由",["客户端路由缓存续用","namesrv 重启恢复"],"【论证】"),
("ROCKETMQ","REPLICALOST"):("停 slave","复制",["主继续服务"],"【论证】"),
("ROCKETMQ","STARTSEQ"):("先 namesrv 后 broker","就绪",["启动顺序断言"],"【论证】03-67"),
("ROCKETMQ","GRACEFUL"):("broker shutdown","在途",["优雅下线"],"【论证】"),
("ROCKETMQ","FORCEKILL"):("kill -9","commitlog 校验",["恢复后消息完整"],"【论证】"),
("ROCKETMQ","ROLLING"):("逐 broker","服务连续",["无中断窗口"],"【论证】"),
("ROCKETMQ","MEMWATER"):("堆压测","GC",["停顿特征"],"【论证】03-68"),
("ROCKETMQ","GCPRESS"):("JVM 填充","停顿",["特征"],"【论证】"),
("ROCKETMQ","PAGECACHE"):("-","-","","—"),
("ROCKETMQ","HOTRELOAD"):("broker.conf 子集","reload",["生效域"],"【论证】03-67"),
("ROCKETMQ","DYNCONFIG"):("-","-","","—"),
("ROCKETMQ","INVALIDCFG"):("非法配置","启动",["拒绝"],"【论证】"),
("ROCKETMQ","METARESTORE"):("namesrv 恢复","路由",["路由表恢复"],"【论证】"),
("ROCKETMQ","LOGREPAIR"):("-","-","","—"),
("ROCKETMQ","QUOTA"):("-","-","","—"),
("ROCKETMQ","CONNLIMIT"):("连接风暴","accept",["行为"],"【论证】"),
("ROCKETMQ","MSGSIZE"):("超 4MB 默认","生产",["拒绝"],"【论证】01-72"),
("ROCKETMQ","REBALPRODUCE"):("consumer 组变更","生产连续",["无中断"],"【论证】"),
("ROCKETMQ","CLIENTFLOOD"):("-","-","","—"),
("ROCKETMQ","RECONNSTORM"):("-","-","","—"),
("ROCKETMQ","CLIENTVERS"):("-","-","","—"),
("REDIS","DISKFULL"):("AOF 目录满","写入",["写拒绝/只读模式","清理恢复"],"03-68"),
("REDIS","DISKSLOW"):("AOF everysec 慢盘","持久化",["fsync 延迟指标"],"03-68"),
("REDIS","NETPART"):("隔离 replica","复制",["主库继续服务","恢复后 psync"],"03-68"),
("REDIS","BROKERKILL"):("kill -9","RTO+RDB/AOF",["AOF everysec 丢失≤1s 窗口声明","重启加载时长"],"03-68/01-67"),
("REDIS","METALOSS"):("-","-","","—"),
("REDIS","REPLICALOST"):("停 replica","复制",["主服务不受影响","replica 重同步"],"03-68"),
("REDIS","STARTSEQ"):("compose 起","就绪",["加载 AOF 完成前拒绝服务"],"03-68"),
("REDIS","GRACEFUL"):("SHUTDOWN SAVE","落盘",["持久化完成才退出"],"03-68"),
("REDIS","FORCEKILL"):("kill -9","AOF/RDB",["everysec 窗口内丢数据声明","重放一致"],"03-68"),
("REDIS","ROLLING"):("主从切换重启","服务连续",["failover 窗口"],"03-68"),
("REDIS","MEMWATER"):("maxmemory 满+allkeys-lru","写入",["驱逐行为符合策略","evicted_keys 指标"],"03-68"),
("REDIS","GCPRESS"):("-","-","","—"),
("REDIS","PAGECACHE"):("drop_caches","AOF",["重写/读取性能回退"],"03-68"),
("REDIS","HOTRELOAD"):("CONFIG SET 全集","生效域",["运行时全量（对照 03-67）"],"03-67"),
("REDIS","DYNCONFIG"):("CONFIG SET vs 配置文件","一致性",["运行时与持久化对账"],"03-67"),
("REDIS","INVALIDCFG"):("非法配置","启动",["拒绝"],"03-68"),
("REDIS","METARESTORE"):("-","-","","—"),
("REDIS","LOGREPAIR"):("-","-","","—"),
("REDIS","QUOTA"):("（无配额——反向用例）","超限",["系统不承诺配额语义"],"01-66/TEST-C2"),
("REDIS","CONNLIMIT"):("maxclients 风暴","连接",["拒绝+maxclients 错误"],"03-68"),
("REDIS","MSGSIZE"):("超 proto-max-bulk-len=512MB（01-72）","XADD",["拒绝"],"01-72"),
("REDIS","REBALPRODUCE"):("-","-","","—"),
("REDIS","CLIENTFLOOD"):("短连接","FD",["行为"],"03-68"),
("REDIS","RECONNSTORM"):("重连","曲线",["无失控"],"04-03"),
("REDIS","CLIENTVERS"):("-","-","","—"),
("MQTT","DISKFULL"):("mosquitto 持久会话目录满","QoS1 发布",["存储错误行为"],"03-68"),
("MQTT","DISKSLOW"):("慢盘","持久化会话",["延迟上升"],"03-68"),
("MQTT","NETPART"):("桥接链路分区","桥接",["离线缓冲/丢弃策略","恢复补传"],"03-68"),
("MQTT","BROKERKILL"):("kill broker","会话",["cleanSession=false 客户端重连","持久会话恢复"],"03-68"),
("MQTT","METALOSS"):("-","-","","—"),
("MQTT","REPLICALOST"):("-","-","","—"),
("MQTT","STARTSEQ"):("mosquitto 起","监听",["listener 1883/8883 双就绪"],"03-68"),
("MQTT","GRACEFUL"):("SIGTERM","在途 inflight",["持久会话落盘"],"03-68"),
("MQTT","FORCEKILL"):("kill -9","会话",["持久会话声明边界"],"03-68"),
("MQTT","ROLLING"):("broker 重启","客户端",["自动重连"],"03-68"),
("MQTT","MEMWATER"):("大消息+连接洪峰","内存",["max_inflight/内存水位"],"03-68"),
("MQTT","GCPRESS"):("-","-","","—"),
("MQTT","PAGECACHE"):("-","-","","—"),
("MQTT","HOTRELOAD"):("mosquitto reload","配置热载",["生效域"],"03-67"),
("MQTT","DYNCONFIG"):("-","-","","—"),
("MQTT","INVALIDCFG"):("非法 mosquitto.conf","启动",["拒绝+行号"],"03-68"),
("MQTT","METARESTORE"):("-","-","","—"),
("MQTT","LOGREPAIR"):("-","-","","—"),
("MQTT","QUOTA"):("-","-","","—"),
("MQTT","CONNLIMIT"):("max_connections 风暴","连接",["拒绝行为"],"03-68"),
("MQTT","MSGSIZE"):("超 maximum-packet-size（v5 属性）","CONNECT/PUBLISH",["拒绝+0x95（01-64）"],"01-64/01-72"),
("MQTT","REBALPRODUCE"):("共享订阅组成员变化","发布连续",["$share 分发重排无中断"],"01-64"),
("MQTT","CLIENTFLOOD"):("连接风暴","accept",["行为"],"03-68"),
("MQTT","RECONNSTORM"):("十万设备重连风暴（弱网回放）","曲线",["重连雪崩防护"],"01-46/04-03"),
("MQTT","CLIENTVERS"):("3.1.1 与 5.0 客户端混连","协议协商",["CONNACK 版本标识","v5 属性不被 3.x 误读"],"01-64"),
}
CAT_DEFAULT = {
 "fault": ("注入故障至系统边界","观察默认行为",["行为符合 03-68 故障行为表","恢复后服务收敛","RTO 记录入 trends 表"]),
 "lifecycle": ("标准拓扑","生命周期动作",["行为符合 03-68 生命周期节","无未承诺的数据丢失"]),
 "resource": ("资源压测至边界","观察",["水位/alarm 行为符合 03-68 资源模型","无未预期崩溃"]),
 "config": ("配置变更","生效/回读",["生效域符合 03-67 配置面画像","非法值拒绝可读"]),
 "restore": ("损坏/删除后恢复","恢复动作",["恢复一致性","坏数据隔离"]),
 "quota": ("超限压测","观察",["拒绝/限流可观测","错误信息可读"]),
 "clientops": ("客户端行为注入","观察",["系统行为符合预期","无雪崩失控"]),
}
SRC_DEFAULT = "03-68 运行行为档案"

def load_catalog():
    rows = []
    with open(CAT, encoding="utf-8") as f:
        for line in f:
            if line.startswith("#") or not line.strip() or line.startswith("code"): continue
            c = line.rstrip("\r\n").split("\t")
            rows.append({"code":c[0],"category":c[1],"name":c[2],"applic":c[3],"src":c[5] if len(c)>5 else SRC_DEFAULT})
    return rows

def applicable(appsys, sys_):
    if appsys == "全部": return True
    if appsys.startswith("LINUX"): return True
    if appsys.startswith("JVM"): return sys_ in ("KAFKA","RABBITMQ","PULSAR","ROCKETMQ")
    parts = [p.strip() for p in appsys.split(",")]
    for p in parts:
        if p == sys_: return True
        if p.startswith(sys_+"(") or p.startswith(sys_): return True
    return False

cat = load_catalog()
made, reg_rows = 0, []
for item in cat:
    for sys_ in ["KAFKA","RABBITMQ","NATS","PULSAR","ROCKETMQ","REDIS","MQTT"]:
        if not applicable(item["applic"], sys_): continue
        kb = KB.get((sys_, item["code"]))
        if kb and kb[0] == "-": continue
        if kb:
            given, when, thens, src = kb
        else:
            given, when, thens = CAT_DEFAULT[item["category"]][:3]
            thens = CAT_DEFAULT[item["category"]][2]
            src = item["src"]
        cid = f"TC-OPS-{sys_}-{item['code']}-01"
        d = os.path.join(BASE, "cases", sys_.lower(), item["code"].lower())
        os.makedirs(d, exist_ok=True)
        body = f"""# {cid}：{sys_} {item['name']} 运维行为测试

> **维度**：系统={sys_} | 行为={item['code']}（{item['category']} 类）| 断言面：CLI/admin/metrics（语言无关）
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
bash Testing/08-运维行为测试/cases/{sys_.lower()}/{item['code'].lower()}/{cid}.sh   # 计划打印（挂账）
```

## 关联
- {src}；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
"""
        open(os.path.join(d, cid + ".md"), "w", encoding="utf-8", newline="\n").write(body)
        reg_rows.append(f"{cid}\tOPS\t-\tE2\t08-运维行为测试\tpending")
        made += 1

with open(os.path.join(ROOT, "topics", "scripts", "test-registry.tsv"), "a", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(reg_rows) + "\n")
print(f"ops_cases={made}")
