#!/usr/bin/env python3
# 批次120+/挂账1+4：560格 GWT 充实 + RocketMQ 语义格补边
# 知识库（KB）逐格手工内容；语义格等级依据 TEST-C2（RocketMQ 列为本脚本补定【论证】）
# 用法：python3 matrix-enrich.py   （重写骨架文件 + 建 RocketMQ 格 + 更新 matrix/test-registry + graph.jsonld）
import os, re, json, csv

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "07-集成矩阵")

DEG = {
 "KAFKA":   {"DLV":"n","ORD":"n","IDM":"n","RET":"c","DLQ":"c","TRX":"n","BCK":"n","TTL":"a","DLY":"a","FLT":"a","FLW":"n","PST":"n"},
 "RABBITMQ":{"DLV":"n","ORD":"n","IDM":"a","RET":"a","DLQ":"n","TRX":"a","BCK":"n","TTL":"n","DLY":"c","FLT":"n","FLW":"n","PST":"n"},
 "NATS":    {"DLV":"c","ORD":"c","IDM":"c","RET":"n","DLQ":"c","TRX":"x","BCK":"n","TTL":"n","DLY":"a","FLT":"n","FLW":"n","PST":"c"},
 "PULSAR":  {"DLV":"n","ORD":"n","IDM":"c","RET":"n","DLQ":"n","TRX":"n","BCK":"n","TTL":"n","DLY":"n","FLT":"c","FLW":"n","PST":"n"},
 "ROCKETMQ":{"DLV":"n","ORD":"n","IDM":"a","RET":"c","DLQ":"n","TRX":"n","BCK":"c","TTL":"a","DLY":"n","FLT":"n","FLW":"c","PST":"n"},
 "REDIS":   {"DLV":"a","ORD":"n","IDM":"a","RET":"a","DLQ":"x","TRX":"x","BCK":"a","TTL":"x","DLY":"a","FLT":"a","FLW":"a","PST":"n"},
 "MQTT":    {"DLV":"n","ORD":"c","IDM":"a","RET":"c","DLQ":"a","TRX":"x","BCK":"n","TTL":"n","DLY":"a","FLT":"n","FLW":"c","PST":"c"},
}
DEGTXT = {"n":("native","●","正例断言"),"c":("config","◐","配置启用后正例"),
          "a":("app-level","○","应用层模式用例（契约兜底）"),"x":("none","—","反向用例（系统不承诺，防误用）")}

# KB[(sys, feat)] = (given, when, [then...], link)  —— 逐格手工
KB = {
("KAFKA","DLV"):("3 broker KRaft，min.insync.replicas=2；acks=all+幂等生产者","生产 500 条后 kill 确认副本",["已确认消息不丢（ASE-001）","重复计数≤1"],"01-61 ISR 语义"),
("KAFKA","ORD"):("单分区 topic；并发 3 生产者","产 1000 条",["分区内消费序=偏移序","跨分区无序合法"],"01-61/TEST-C2 顺序性"),
("KAFKA","IDM"):("enable.idempotence=true","broker 故障转移触发重试",["单分区日志无重复序列号"],"01-63 KIP-98"),
("KAFKA","RET"):("delivery.timeout.ms+retries（无退避）","持续 nack 场景",["重试次数可观测；无退避声明（等级◐依据）"],"01-66/02-16"),
("KAFKA","DLQ"):("Kafka 4.4（fixtures 已锁）；share group + share.dlq.topic","毒消息至 delivery 上限",["入 DLQ 且主 share 不停（KIP-1191）","4.4 前无原生=配置等级"],"01-65/TC-KAFKA-GO-DLQ-01"),
("KAFKA","TRX"):("事务生产者+read_committed 消费者","跨分区事务提交/中止",["仅已提交可见","中止事务不可见（Jepsen 边界见 conformance-matrix）"],"01-63/KAFKA-17754"),
("KAFKA","BCK"):("producer buffer.memory 满；consumer fetch 上限","生产速率>消费速率",["producer 阻塞非报错（设计行为）","fetch 限流生效"],"01-66"),
("KAFKA","TTL"):("topic retention（无 per-message TTL）","消息超保留期",["过期段清理可观测","消息级 TTL 需应用层（等级○依据）"],"01-72/TEST-C2"),
("KAFKA","DLY"):("无原生；定时任务模拟","延迟投递需求",["应用层调度器模式断言"],"02-16/TEST-C2 ○"),
("KAFKA","FLT"):("服务端过滤有限（客户端过滤为主）","按条件消费",["客户端过滤正确性","服务端 filter 挂账"],"TEST-C2/02-13"),
("KAFKA","FLW"):("fetch.max.bytes/quota","高并发拉取",["配额限流可观测"],"01-71 fetch 全字段"),
("KAFKA","PST"):("segment+副本持久化","broker 重启",["已提交段完整","页缓存依赖声明"],"01-61"),
("RABBITMQ","DLV"):("durable queue+persistent 消息+confirm","broker 重启",["消息存活（ASE-015 族）","confirm 返回即承诺"],"01-65"),
("RABBITMQ","ORD"):("单队列 FIFO","并发生产",["队列内严格有序"],"TEST-C2"),
("RABBITMQ","IDM"):("无 broker 去重","重投场景",["应用层幂等键模式"],"02-25"),
("RABBITMQ","RET"):("客户端重连+nack 重投","瞬时故障",["重投可观测；无退避序列"],"01-65"),
("RABBITMQ","DLQ"):("DLX 绑定；nack(requeue=false)","毒消息",["入 DLQ 原队列清空（ASE-007）","DLQ 可再消费"],"01-65 AMQP 路径"),
("RABBITMQ","TRX"):("AMQP tx 单消息事务","多消息原子需求",["无跨消息事务——应用层模式（等级○）"],"01-42/01-63"),
("RABBITMQ","BCK"):("basic.qos prefetch","慢消费",["未确认数=平台期"],"ASE-011"),
("RABBITMQ","TTL"):("per-message TTL+队列 TTL","过期消息",["过期即清理可观测"],"TEST-C2 ●"),
("RABBITMQ","DLY"):("延迟插件/TTL+DLX 模式","延迟投递",["插件模式断言（等级◐）"],"01-65/02-16"),
("RABBITMQ","FLT"):("routing key+headers+binding","多条件路由",["绑定键路由正确"],"02-13"),
("RABBITMQ","FLW"):("credit flow（AMQP 1.0）","过载",["信用耗尽行为可观测"],"01-66"),
("RABBITMQ","PST"):("durable 声明矩阵","重启",["队列+消息存活"],"03-68"),
("NATS","DLV"):("JetStream workqueue+explicit ack；Core 至多一次对照","消费端中断重启",["未 ack 重投","AckFloor 单调"],"01-66"),
("NATS","ORD"):("JetStream ordered consumer","乱序注入",["有序 consumer 序列断言（◐需 JetStream）"],"01-66"),
("NATS","IDM"):("Msg-Id 去重窗口","窗口内重复发布",["仅首条持久化（ASE-005）"],"01-63"),
("NATS","RET"):("maxDeliver+backoff 序列","持续失败",["退避逐档断言（ASE-006）"],"01-66 ●"),
("NATS","DLQ"):("maxDeliver 耗尽→DLQ subject","毒消息",["DLQ subject 收到","delivery count 可观测"],"01-65"),
("NATS","TRX"):("无事务","事务需求",["系统不承诺（反向用例）——用 outbox 模式（02-47）"],"TEST-C2 —"),
("NATS","BCK"):("maxAckPending=100 不 ack","持续投递",["平台期=100（ASE-010）"],"01-66/TC-NATS-GO-BCK-01"),
("NATS","TTL"):("maxAge/消息 TTL","过期",["过期清理可观测"],"TEST-C2 ●"),
("NATS","DLY"):("无原生延迟","定时需求",["应用层调度模式"],"TEST-C2 ○"),
("NATS","FLT"):("subject 通配符","模式订阅",["通配匹配正确"],"01-66 ●"),
("NATS","FLW"):("pending limits","洪峰",["限额行为可观测"],"TEST-C2 ●"),
("NATS","PST"):("JetStream 持久（Core 内存对照）","重启",["流数据存活"],"01-66 ◐"),
("PULSAR","DLV"):("持久 topic+副本","确认后宕机",["已确认不丢"],"01-62"),
("PULSAR","ORDV" if False else "ORD"):("分区有序；Key_Shared 键序","键散列生产",["键内有序跨键并行"],"01-62"),
("PULSAR","IDM"):("broker deduplication 开关","重复发布",["去重生效（◐需开开关）"],"01-62"),
("PULSAR","RET"):("negative ack 延迟重投","失败重投",["重投延迟可配"],"01-66 ●"),
("PULSAR","DLQ"):("namespace DLQ policy","nack 超 maxRedeliverCount",["入 DLQ topic（ASE-008）"],"01-65 ●"),
("PULSAR","TRX"):("事务（2.8+）","跨分区事务",["提交/中止语义（01-63 对照）"],"01-63 ●"),
("PULSAR","BCK"):("receiverQueueSize","慢消费",["平台期=配置值"],"01-66 ●"),
("PULSAR","TTL"):("topic ttl","过期",["过期消息不可见"],"01-62 ●"),
("PULSAR","DLY"):("deliverAfter 原生","延迟投递",["时间窗可见性（ASE-013）"],"TEST-C2 ●"),
("PULSAR","FLT"):("subscription filtering","过滤订阅",["服务端过滤正确（◐）"],"TEST-C2"),
("PULSAR","FLW"):("receiver queue 信用","过载",["信用行为可观测"],"01-66"),
("PULSAR","PST"):("持久/非持久 topic 对照","重启",["持久 topic 存活"],"01-62"),
("ROCKETMQ","DLV"):("commitlog 持久化+消费确认","broker 宕机恢复",["已确认消息不丢"],"【论证】版本核实入季度复核"),
("ROCKETMQ","ORDV" if False else "ORD"):("分区顺序消息（MessageQueueSelector）","同键生产",["键内有序消费"],"【论证】"),
("ROCKETMQ","IDM"):("应用层幂等键","重投",["幂等键去重模式"],"【论证】"),
("ROCKETMQ","RET"):("consumer 重试等级（%RETRY%）","消费失败",["重试 16 次梯度（◐）"],"【论证】"),
("ROCKETMQ","DLQ"):("重试耗尽→%DLQ%","毒消息",["进死信组+人工可捞"],"【论证】"),
("ROCKETMQ","TRX"):("half message+回查","事务消息",["提交/回滚语义（01-63 对照）"],"【论证】"),
("ROCKETMQ","BCK"):("消费限流/暂停","慢消费",["限流生效（◐）"],"【论证】"),
("ROCKETMQ","TTL"):("保留期 7 天（无消息级 TTL）","超期",["清理可观测；消息级需应用层"],"【论证】"),
("ROCKETMQ","DLY"):("18 级延迟等级原生","延迟投递",["等级时间窗断言"],"【论证】●"),
("ROCKETMQ","FLT"):("SQL92 过滤表达式","条件消费",["过滤表达式生效"],"【论证】"),
("ROCKETMQ","FLW"):("消费限流","过载",["限流行为可观测"],"【论证】◐"),
("ROCKETMQ","PST"):("commitlog+consumequeue","重启",["消息存活"],"【论证】"),
("REDIS","DLV"):("AOF+消费组 PEL","消费端重启",["PEL 重投（应用层承诺）"],"ASE-014"),
("REDIS","ORD"):("Stream ID 单调","乱序 XADD",["ID 单调序"],"TEST-C2 ●"),
("REDIS","IDM"):("XADD 应用层去重","重复生产",["幂等键模式"],"TEST-C2 ○"),
("REDIS","RET"):("应用层重试","失败",["模式断言"],"TEST-C2 ○"),
("REDIS","DLQ"):("无原生 DLQ","毒消息",["反向用例：XAUTOCLAIM 模式为应用层（等级—）"],"01-65"),
("REDIS","TRX"):("无事务","事务需求",["反向用例——Lua 原子替代"],"TEST-C2 —"),
("REDIS","BCK"):("无原生背压","洪峰",["轮询补偿模式（01-66）"],"○"),
("REDIS","TTL"):("无消息级 TTL","过期需求",["反向用例——MAXLEN 是容量非时间"],"TEST-C2 —"),
("REDIS","DLY"):("无原生","定时",["应用层模式"],"○"),
("REDIS","FLT"):("无服务端过滤","过滤",["客户端模式"],"○"),
("REDIS","FLW"):("无流控","过载",["应用层限流模式"],"○"),
("REDIS","PST"):("AOF everysec+RDB","重启",["XLEN 与 ID 保持（ASE-014）"],"ASE-014"),
("MQTT","DLV"):("QoS1 订阅+会话保留","断连重连",["inflight 重投（QoS 分级对照组）"],"01-64 【定理】"),
("MQTT","ORD"):("有序通道；QoS1 重可致重复","网络乱序",["通道有序重复可见（◐）"],"01-64"),
("MQTT","IDM"):("应用层","重复发布",["幂等键模式"],"○"),
("MQTT","RET"):("重连即重试","断连",["重连行为断言"],"◐"),
("MQTT","DLQ"):("实现层（$DLQ 惯例）","失败消息",["应用层 $DLQ 隔离模式"],"01-65 ○"),
("MQTT","TRX"):("无事务","事务需求",["反向用例"],"—"),
("MQTT","BCK"):("Receive Maximum 流控","慢订阅",["窗口信用生效（01-64）"],"●"),
("MQTT","TTL"):("消息过期间隔（v5）","离线过期",["过期不投递（ASE-012）"],"01-64 【定理】"),
("MQTT","DLY"):("无原生","定时",["应用层模式"],"○"),
("MQTT","FLT"):("topic 通配符订阅","模式过滤",["通配匹配正确【定理】"],"01-64"),
("MQTT","FLW"):("inflight 窗口","过载",["窗口满行为"],"◐"),
("MQTT","PST"):("broker 配置决定","重启",["持久会话+保留消息断言"],"◐"),
}
OPS = {
("KAFKA","DEP"):("KRaft 单节点/集群compose","起停拓扑",["启动序列符合 03-68"],"03-67/03-68"),
("KAFKA","UPG"):("滚动升级路径","版本跳转",["升级预检（skill mq-ops-kafka-upgrade）"],"03-67/AI_Skills"),
("KAFKA","FTB"):("磁盘满/副本失联","故障注入",["ISR 收缩行为（01-61 推演表实测）"],"03-68/01-61"),
("KAFKA","OBS"):("JMX 指标面","常态运行",["滞后/请求处理时间基线形态"],"03-68/01-33"),
("RABBITMQ","DEP"):("单节点/镜像队列","起停",["definitions 导入导出"],"03-67"),
("RABBITMQ","UPG"):("版本升级","蓝绿/滚动",["升级窗口行为"],"03-67"),
("RABBITMQ","FTB"):("内存/磁盘 alarm","故障注入",["alarm 触发的写行为（03-68）"],"03-68"),
("RABBITMQ","OBS"):("rabbitmqctl/metrics","常态",["队列深度/ Erlang scheduler 基线"],"03-68"),
("NATS","DEP"):("单节点/JetStream 集群","起停",["拓扑变更行为"],"03-67"),
("NATS","UPG"):("配置热重载","reload",["reload 信号生效（03-68）"],"03-67"),
("NATS","FTB"):("磁盘满/ JetStream 限额","注入",["限额行为"],"03-68"),
("NATS","OBS"):("/varz+consumer info","常态",[" JetStream 指标基线"],"03-68"),
("PULSAR","DEP"):("broker/bookie 分离拓扑","起停",["分层启动序列"],"03-67/01-62"),
("PULSAR","UPG"):("滚动升级","升级",["升级窗口行为"],"03-67"),
("PULSAR","FTB"):("bookie 宕机","注入",["ledger 恢复（01-62 恢复协议实测）"],"01-62/03-68"),
("PULSAR","OBS"):("broker/bookie 双指标面","常态",["存储/计算分层基线"],"03-68"),
("ROCKETMQ","DEP"):("namesrv+broker 拓扑","起停",["启动序列（先 namesrv）"],"【论证】03-67"),
("ROCKETMQ","UPG"):("broker 升级","升级",["升级路径断言"],"【论证】"),
("ROCKETMQ","FTB"):("broker 宕机","注入",["主从切换行为"],"【论证】"),
("ROCKETMQ","OBS"):("broker stats","常态",["基线形态"],"【论证】"),
("REDIS","DEP"):("单节点/副本","起停",["启动行为"],"03-67"),
("REDIS","UPG"):("版本升级","升级",["行为断言"],"03-67"),
("REDIS","FTB"):("内存满 eviction","注入",["驱逐策略行为（03-68 OOM 前兆）"],"03-68"),
("REDIS","OBS"):("INFO/慢日志","常态",["基线形态"],"03-68"),
("MQTT","DEP"):("mosquitto 模板","起停",["listener/WS 双监听"],"03-67"),
("MQTT","UPG"):("broker 升级","升级",["会话迁移行为"],"03-67"),
("MQTT","FTB"):("连接风暴","注入",["连接数上限行为"],"03-68"),
("MQTT","OBS"):("$SYS 主题","常态",["$SYS 指标基线"],"03-68"),
}
FEAT_NAME = {}
with open(os.path.join(BASE,"维度定义","features.tsv"), encoding="utf-8") as f:
    for line in f:
        if line.startswith("#") or not line.strip() or line.startswith("code"): continue
        c = line.rstrip("\r\n").split("\t"); FEAT_NAME[c[0]] = c[1]

def render(cid, sys_, lang, feat):
    ftype_sem = feat in DEG.get(sys_, {})
    if ftype_sem:
        deg = DEG[sys_][feat]
        dn, dg, dt = DEGTXT[deg]
        g, w, thens, link = KB[(sys_, feat)]
        hdr = (f"> **维度**：系统={sys_} | 语言={lang} | 特性={feat}({FEAT_NAME[feat]}) | 转换链=T4\n"
               f"> **矩阵等级**：{dg} {dn}（{dt}）| **断言源**：TEST-C2 {FEAT_NAME[feat]}格\n"
               f"> **环境**：E2 docker；**状态**：pending")
        then = "".join(f"- {t}\n" for t in thens) + f"- 等级依据：TEST-C2 {sys_}×{FEAT_NAME[feat]}={dg}\n"
    else:
        g, w, thens, link = OPS[(sys_, feat)]
        hdr = (f"> **维度**：系统={sys_} | 语言={lang} | 特性={feat}({FEAT_NAME[feat]}) | 转换链=T3,T4\n"
               f"> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending")
        then = "".join(f"- {t}\n" for t in thens)
    return f"""# {cid}：{lang} 客户端的 {sys_} {FEAT_NAME[feat]} 用例

{hdr}

## Given
- {g}

## When
- {w}

## Then
{then}
## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/{sys_.lower()}/{lang.lower()}/{FEAT_NAME[feat]}/{cid}.sh   # 计划打印（挂账）
```

## 关联
- {link}
"""

# 1) 重写既有骨架（含 RocketMQ 新建：60 语义 + 20 运维）
syslangs = {"KAFKA":["GO","PY","TS","RS","C"],"RABBITMQ":["GO","PY","TS","RS","C"],"NATS":["GO","PY","TS","RS","C"],
            "PULSAR":["GO","PY","TS","RS","C"],"REDIS":["GO","PY","TS","RS","C"],"MQTT":["GO","PY","TS","RS","C"],
            "ROCKETMQ":["GO","PY","TS","RS","C"]}
rewritten, created, mnew = 0, 0, []
for sys_, langs_ in syslangs.items():
    for lang in langs_:
        for feat, fname in FEAT_NAME.items():
            cid = f"TC-{sys_}-{lang}-{feat}-01"
            p = os.path.join(BASE,"cases",sys_.lower(),lang.lower(),fname,cid+".md")
            new = render(cid, sys_, lang, feat)
            if os.path.isfile(p):
                old = open(p, encoding="utf-8").read()
                if "（骨架）" in old or "挂账——逐批回填 ASE" in old:
                    open(p,"w",encoding="utf-8",newline="\n").write(new); rewritten += 1
            else:
                os.makedirs(os.path.dirname(p), exist_ok=True)
                open(p,"w",encoding="utf-8",newline="\n").write(new); created += 1
                mnew.append(f"{cid}\t{sys_}\t{lang}\t{feat}\tT4\tpending\t-")
if mnew:
    with open(os.path.join(BASE,"matrix-registry.tsv"),"a",encoding="utf-8",newline="\n") as f:
        f.write("\n".join(mnew)+"\n")
    treg = set(l.split("\t")[0] for l in open(os.path.join(ROOT,"topics/scripts/test-registry.tsv"),encoding="utf-8") if l.strip() and not l.startswith("#"))
    with open(os.path.join(ROOT,"topics/scripts/test-registry.tsv"),"a",encoding="utf-8",newline="\n") as f:
        f.write("".join(f"{c}\tMAT\t-\tE2\t07-集成矩阵\tpending\n" for c in mnew if c.split("\t")[0] not in treg))

# 2) graph.jsonld 补 RocketMQ 能力边
gp = os.path.join(ROOT,"topics","knowledge-graph","graph.jsonld")
g = json.load(open(gp, encoding="utf-8"))
node = next((n for n in g["graph"] if n.get("id")=="mq:system-rocketmq"), None)
if node is None:
    node = {"id":"mq:system-rocketmq","type":"mq:System","name":"RocketMQ","source":"TEST-C2 补记（批次120+）","note":"语义格为【论证】定级，版本事实季度复核"}
    g["graph"].append(node)
node["supportedBy"] = [{"id":f"mq:dim-{ {'DLV':'delivery','ORD':'ordering','IDM':'dedup','RET':'retry','DLQ':'dlq','TRX':'transaction','BCK':'backpressure','TTL':'ttl','DLY':'delay','FLT':'filtering','FLW':'flowctl','PST':'persistence'}[f] }", "degree":DEGTXT[DEG['ROCKETMQ'][f]][0]}
    for f in DEG["ROCKETMQ"]]
json.dump(g, open(gp,"w",encoding="utf-8"), ensure_ascii=False, indent=1)
print(f"rewritten={rewritten} created={created} mnew={len(mnew)}")
