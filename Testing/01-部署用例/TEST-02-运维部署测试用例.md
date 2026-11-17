# T.02 运维部署测试用例

> **本文档定位**：部署层的可执行用例库——安装部署、配置校验、升级回滚、备份恢复四类（TC-DEP-01~15c）。设计论证见 02 系列与 03-01；本文档只给"命令 + 预期输出 + 通过标准"。

## 目录

- [T.02 运维部署测试用例](#t02-运维部署测试用例)
  - [目录](#目录)
  - [T.02.1 范围与环境](#t021-范围与环境)
  - [T.02.2 安装部署用例](#t022-安装部署用例)
  - [T.02.3 配置校验用例](#t023-配置校验用例)
  - [T.02.4 升级与回滚用例](#t024-升级与回滚用例)
  - [T.02.5 备份恢复用例](#t025-备份恢复用例)
  - [T.02.6 部署测试总检查清单](#t026-部署测试总检查清单)
  - [T.02.7 参考来源](#t027-参考来源)

---

## T.02.1 范围与环境

用例默认在 `topics/config-templates/` 的 compose 模板上执行；无 Docker 环境时标记 SKIP 并仅执行静态校验用例（TC-DEP-05/09）。

| 环境资产 | 用途 |
| ---------- | ------ |
| `docker-compose-kafka.yml` | TC-DEP-01 Kafka 多 broker 部署（服务名 kafka-1/2/3，当前为 ZK 模式镜像模板） |
| `docker-compose-nats.yml` | TC-DEP-02 NATS + JetStream 部署 |
| `docker-compose-rabbitmq.yml` | TC-DEP-03 RabbitMQ quorum 队列部署 |
| `docker-compose-all.yml` | 多系统共存与端口冲突检查 |
| `apache/rocketmq:5.5.0`（官方镜像） | TC-DEP-04c/11b/15b 单机验证（项目暂无 RocketMQ compose 模板） |
| `redpandadata/redpanda:v26.1.12`（官方镜像） | TC-DEP-04d/11c/15c 单机验证（项目暂无 Redpanda compose 模板） |
| `scripts/deploy-*.sh`、`validate-config.sh`、`upgrade-check.sh`、`backup-verify.sh` | 执行器 |

> 注：compose 模板沿用项目现有镜像（cp-kafka 为 ZooKeeper 模式）；KRaft 模板化属后续治理项，用例命令以服务名 `kafka-1` 为准。RocketMQ/Redpanda 用例使用官方 Docker 镜像单机运行并注明来源。

```bash
# 环境预检（任一不满足则运行类用例全部 SKIP）
docker info >/dev/null 2>&1 || { echo "SKIP: 无 docker"; exit 0; }
docker compose version >/dev/null 2>&1 || { echo "SKIP: 无 compose v2"; exit 0; }
df -h /var/lib/docker | awk 'NR==2{exit !($4+0>10)}'  # 磁盘余量 >10G
```

## T.02.2 安装部署用例

> 本节新增 TC-DEP-04c/04d（RocketMQ/Redpanda 单节点 Docker 部署），镜像与版本经 WebSearch 核实至 2026-11：官方镜像 `apache/rocketmq:5.5.0`、`redpandadata/redpanda:v26.1.12`。

用例统一字段结构（所有 TC-DEP 用例按此编写，缺字段视为用例缺陷）：

```text
TC-DEP-NN <名称>
  目的:      验证什么（一句话）
  前置条件:  环境/工具/数据前提
  步骤:      编号命令序列（可复制执行）
  预期输出:  每步的命令输出要点
  通过标准:  量化判定（禁止"正常""无误"式空泛）
  失败处置:  按 TEST-05 分类的预设归类（P/T/E/D/B）
```

**TC-DEP-01 Kafka 多 broker 部署（compose-kafka）**:

- 目的：验证单节点 KRaft 可起、可创建 topic、可生产消费
- 步骤：

```bash
docker compose -f topics/config-templates/docker-compose-kafka.yml up -d
# 等待就绪（compose-kafka 服务名为 kafka-1/2/3）
for i in $(seq 1 30); do
  docker exec kafka-1 kafka-topics.sh --bootstrap-server localhost:9092 --list >/dev/null 2>&1 && break
  sleep 2
done
```

- 预期输出：`kafka-topics.sh --list` 返回（空列表即成功，退出码 0）；`kafka-broker-api-versions.sh` 显示版本 ≥ 3.x
- 通过标准：创建 topic `tc-dep-01`（`--partitions 3 --replication-factor 1`）成功；`kafka-console-producer/consumer` 往返一条消息

**TC-DEP-02 NATS + JetStream 部署**:

- 步骤：`docker compose -f topics/config-templates/docker-compose-nats.yml up -d`；`nats server check jetstream -s nats://localhost:4222`
- 通过标准：`nats stream add TC_DEP_02 --subjects tc.dep.02 --storage file --defaults` 成功；`nats pub tc.dep.02 hello` + `nats sub` 往返成功

**TC-DEP-03 RabbitMQ quorum 队列部署**:

- 步骤：`docker compose -f topics/config-templates/docker-compose-rabbitmq.yml up -d`；`rabbitmqctl await_startup`
- 通过标准：`rabbitmqadmin declare queue name=tc-dep-03 queue_type=quorum` 成功；`rabbitmq-perf-test -x 1 -y 1 -u tc-dep-03 -z 10` 无错误

**TC-DEP-04 多系统共存部署（compose-all）**:

- 目的：验证 `docker-compose-all.yml` 端口/网络无冲突
- 通过标准：`docker compose -f topics/config-templates/docker-compose-all.yml config -q` 退出码 0；全部服务 healthy

**TC-DEP-04b Redis 与 MQTT 部署（compose-all 单服务提取）**:

- 目的：compose-all 含 redis/mqtt 未单列模板，验证单服务提取部署
- 步骤：

```bash
# Redis Stream 最小部署（临时容器，测完即删）
docker run -d --name tc-dep-redis -p 6379:6379 redis:7-alpine
docker exec tc-dep-redis redis-cli XADD tc '*' f v   # 预期返回 entry id
docker rm -f tc-dep-redis
# MQTT broker 最小部署（eclipse-mosquitto，匿名访问需配置）
docker run -d --name tc-dep-mqtt -p 1883:1883 eclipse-mosquitto
mosquitto_sub -h localhost -t tc/dep -C 1 &  SUB=$!
sleep 1; mosquitto_pub -h localhost -t tc/dep -m ok
wait $SUB   # 预期收到 ok
docker rm -f tc-dep-mqtt
```

- 通过标准：收发往返成功；容器清理后端口释放（`port_free` 断言）

**TC-DEP-04c RocketMQ 单节点 Docker 部署**:

- 目的：验证 `apache/rocketmq:5.5.0` 镜像可启动 NameServer + Broker + Proxy，并完成收发
- 前置条件：Docker 可用；磁盘余量 >10G；端口 9876/10911/8081 空闲
- 步骤：

```bash
# 1. NameServer
docker run -d --name tc-dep-rmq-nsrv -p 9876:9876 \
  apache/rocketmq:5.5.0 sh mqnamesrv
# 2. Broker（连接 NameServer；单机测试 RF=1）
docker run -d --name tc-dep-rmq-broker --link tc-dep-rmq-nsrv:nsrv \
  -p 10911:10911 -e "NAMESRV_ADDR=nsrv:9876" \
  apache/rocketmq:5.5.0 sh mqbroker -n nsrv:9876 --enable-proxy
# 3. 就绪探测（重试 30 次，间隔 2s）
for i in $(seq 1 30); do
  docker exec tc-dep-rmq-broker sh -c \
    "timeout 5 bash -c 'echo > /dev/tcp/nsrv/9876'" && break
  sleep 2
done
```

- 预期输出：`docker logs tc-dep-rmq-broker | grep -i 'broker start'` 成功；`mqadmin clusterList -n 127.0.0.1:9876` 返回 BROKER_NAME
- 通过标准：使用 mqadmin/客户端创建 topic `tc-dep-rmq`（1 队列）并生产/消费一条消息成功
- 失败处置：E（环境）/P（产品）
- 诚实标注：命令基于 [Apache RocketMQ Docker Quickstart](https://rocketmq.apache.org/docs/quickStart/02quickstartWithDocker/) 设计，未在本项目 CI 实际运行

**TC-DEP-04d Redpanda 单节点 Docker 部署**:

- 目的：验证 `redpandadata/redpanda:v26.1.12` 单节点可启动并完成 Kafka 协议收发
- 前置条件：Docker 可用；端口 9092 空闲；建议内存 ≥2G
- 步骤：

```bash
docker run -d --name tc-dep-redpanda -p 9092:9092 \
  redpandadata/redpanda:v26.1.12 \
  redpanda start --overprovisioned --smp 1 --memory 1G \
  --kafka-addr PLAINTEXT://0.0.0.0:9092 \
  --advertise-kafka-addr PLAINTEXT://127.0.0.1:9092
# 就绪探测
for i in $(seq 1 30); do
  docker exec tc-dep-redpanda rpk cluster info >/dev/null 2>&1 && break
  sleep 2
done
```

- 预期输出：`rpk cluster info` 显示 1 broker healthy；`rpk topic list` 返回空列表（退出码 0）
- 通过标准：`rpk topic create tc-dep-redpanda` 成功；`rpk topic produce/consume` 往返一条消息
- 失败处置：E（环境）/P（产品）
- 诚实标注：命令基于 [Redpanda Self-Managed Quickstart](https://docs.redpanda.com/streaming/current/get-started/quick-start/) 设计，未在本项目 CI 实际运行

| 用例 | 系统 | 核心验证点 | 通过标准 |
| ------ | ------ | ----------- | ---------- |
| TC-DEP-01 | Kafka | KRaft 启动/topic/收发 | 收发往返成功，日志无 ERROR |
| TC-DEP-02 | NATS | JetStream 流创建/收发 | stream info 显示 Ready |
| TC-DEP-03 | RabbitMQ | quorum 队列声明/收发 | perf-test 0 错误 |
| TC-DEP-04 | 全系统 | 端口/网络冲突 | `config -q` 通过 + healthy |
| TC-DEP-04c | RocketMQ | NameServer+Broker+Proxy 收发 | mqadmin 创建 topic 并往返 |
| TC-DEP-04d | Redpanda | rpk 单节点启动/Kafka 协议收发 | rpk cluster info healthy |

## T.02.3 配置校验用例

**TC-DEP-05 Kafka server.properties 静态校验（无 Docker 可执行）**:

- 目的：配置模板符合生产基线（与 03-16 安全加固、03-26 检查清单对齐）
- 步骤与预期：

```bash
./topics/scripts/validate-config.sh topics/config-templates/kafka-server.properties.template
# 关键断言（脚本内或人工核查）：
grep -E '^num\.partitions='  kafka-server.properties.template   # 预期 ≥3
grep -E '^default\.replication\.factor=' kafka-server.properties.template  # 预期 ≥2【论证：可用性基线】
grep -E '^min\.insync\.replicas=' kafka-server.properties.template          # 预期 ≥1 且与 RF 协调
grep -E '^unclean\.leader\.election\.enable=' kafka-server.properties.template # 预期 false
```

- 通过标准：四项断言全过；`validate-config.sh` 退出码 0

**TC-DEP-06 客户端配置校验**:

- 断言：`kafka-producer-config.properties` 中 `acks=all`、`enable.idempotence=true`；`kafka-consumer-config.properties` 中 `isolation.level=read_committed`（事务场景）或 `read_uncommitted`（非事务场景，文档须注明）
- 通过标准：关键参数与 03-59 测试策略表中"消息不丢不重"要求一致

**TC-DEP-08c RocketMQ Broker 配置校验**:

- 目的：验证 RocketMQ 模板中同步复制/同步刷盘参数符合生产基线
- 步骤：

```bash
grep -E '^brokerRole=' topics/config-templates/rocketmq-broker.conf  # 预期 SYNC_MASTER
grep -E '^flushDiskType=' topics/config-templates/rocketmq-broker.conf  # 预期 SYNC_FLUSH
```

- 通过标准：上述断言为真；若项目内暂无 `rocketmq-broker.conf` 模板，则标记 SKIP 并记录
- 诚实标注：项目 `config-templates/` 目录暂无 RocketMQ 专属模板，本用例以通用参数断言为主

**TC-DEP-08d Redpanda 配置校验**:

- 目的：验证 Redpanda 模板中幂等、复制数、日志保留参数符合基线
- 步骤：

```bash
grep -E 'enable_idempotence' topics/config-templates/redpanda-server.conf  # 预期 true
grep -E 'default_topic_replications' topics/config-templates/redpanda-server.conf  # 预期 3
grep -E 'log_retention_ms|delete_retention_ms' topics/config-templates/redpanda-server.conf  # 有明确值
```

- 通过标准：上述断言为真；若项目内暂无模板则标记 SKIP 并记录
- 诚实标注：项目 `config-templates/` 目录暂无 Redpanda 专属模板，本用例以通用参数断言为主

| 用例 | 对象 | 关键断言 | 依据 |
| ------ | ------ | ---------- | ------ |
| TC-DEP-05 | Kafka server | RF≥2、min.insync≥1、unclean=false | 01-13/03-16 |
| TC-DEP-06 | Kafka client | acks=all、幂等开启、隔离级别注明 | 03-59 |
| TC-DEP-07 | RabbitMQ | `cluster_partition_handling`、quorum 默认 | 01-15 |
| TC-DEP-08 | NATS | JetStream max_memory_store/max_file_store 上限 | 01-26 |
| TC-DEP-08c | RocketMQ | `brokerRole=SYNC_MASTER`、`flushDiskType=SYNC_FLUSH` | 01-27 |
| TC-DEP-08d | Redpanda | `enable_idempotence=true`、`default_topic_replications=3` | 01-28 |

## T.02.4 升级与回滚用例

**TC-DEP-09 升级前检查（静态，无环境可执行）**:

- 步骤：`./topics/scripts/upgrade-check.sh`（项目已有脚本）
- 通过标准：输出无 BLOCKER 项；目标版本与当前版本的 log message format 兼容（Kafka 跨 major 必须空升级窗口）

**TC-DEP-10 Kafka 滚动升级（4.x 小版本）**:

- 步骤：

```bash
# 逐节点滚动：kafka-1 → kafka-2 → kafka-3
docker compose -f topics/config-templates/docker-compose-kafka.yml stop kafka-1
# 替换镜像 tag 后
docker compose -f topics/config-templates/docker-compose-kafka.yml up -d kafka-1
# 每节点验证
kafka-topics.sh --bootstrap-server localhost:9092 --describe | grep -c "Leader: none"  # 预期 0
```

- 通过标准：全程 URP=0；`kafka-consumer-groups.sh --describe` 无 STUCK 组
- 边界：跨 major（3.x→4.x）含 ZooKeeper 移除，不在本用例覆盖，按 AI_SKILL-04 的 mq-ops-kafka-upgrade 技能流程执行

**TC-DEP-11 配置热更新验证**:

- 步骤：修改 `kafka-server.properties.template` 的 `log.retention.hours` → 滚动重启 → `kafka-configs.sh --describe --entity-type brokers`
- 通过标准：新值生效且旧 segment 按新策略清理

**TC-DEP-11b RocketMQ 小版本升级与回滚**:

- 目的：验证 5.4.x → 5.5.0 小版本升级可回退
- 步骤：

```bash
# 使用 TC-DEP-04c 环境，先以 5.4.0 启动并写入 100 条
docker stop tc-dep-rmq-broker tc-dep-rmq-nsrv
docker rm tc-dep-rmq-broker tc-dep-rmq-nsrv
# 替换镜像 tag 为 5.5.0 后重新启动
# 回滚：再次 stop/rm 并切回 5.4.0 镜像
```

- 通过标准：升级后消费位点连续、消息不丢；回滚后服务可启动；跨 major（4.x→5.x）不在本用例覆盖
- 诚实标注：命令基于官方镜像设计，未在本项目 CI 实际运行

**TC-DEP-11c Redpanda 小版本升级与回滚**:

- 目的：验证 CalVer 小版本（如 v26.1.9 → v26.1.12）升级可回退
- 步骤：单节点 `redpandadata/redpanda:v26.1.9` 写入 topic → stop → 换 `v26.1.12` 启动 → 验证消费 → 回退原镜像
- 通过标准：升级后 `rpk cluster info` healthy、消息可读；回滚后无元数据损坏
- 诚实标注：命令基于 Redpanda 文档设计，未在本项目 CI 实际运行

| 用例 | 场景 | 回滚要求 | 通过标准 |
| ------ | ------ | ---------- | ---------- |
| TC-DEP-09 | 升级预检 | 无（只读） | 无 BLOCKER |
| TC-DEP-10 | 小版本滚动升级 | 镜像 tag 回退 + URP=0 | 收发不间断 |
| TC-DEP-11 | 热更新 | 配置回退重启 | 新参数生效 |
| TC-DEP-11b | RocketMQ 小版本 | 镜像 tag 回退 | 位点连续、可启动 |
| TC-DEP-11c | Redpanda 小版本 | 镜像 tag 回退 | cluster info healthy |

## T.02.5 备份恢复用例

**TC-DEP-12 Kafka 主题元数据备份/恢复**:

- 步骤：`./topics/scripts/backup-all.sh kafka` → 删除测试 topic → `./topics/scripts/restore-all.sh kafka`
- 通过标准：被删 topic 恢复且分区数/RF 一致；数据面按"至少一次"语义校验（备份点后的消息允许缺失，须在报告中声明 RPO）

**TC-DEP-13 NATS JetStream 流快照恢复**:

- 步骤：`nats stream snapshot TC_DEP_02 --file /tmp/backup.tar` → `nats stream rm TC_DEP_02` → 按快照重建
- 通过标准：重建后 `nats stream info` 的 Messages/Bytes 与快照一致

**TC-DEP-14 RabbitMQ quorum 队列数据恢复**:

- 步骤：声明持久化 quorum 队列 → 发 1000 条 → `rabbitmqctl stop_app` 单节点 → 重启 → 消费计数
- 通过标准：消费到 1000 条；队列 leader 重新选举完成时间 < 30s【估算】

**TC-DEP-15 备份介质可用性验证**:

- 步骤：`./topics/scripts/backup-verify.sh`（校验备份文件完整性/可解压/含元数据）
- 通过标准：退出码 0；报告含备份大小、时间戳、校验和

**TC-DEP-15b RocketMQ 消费位点回溯**:

- 目的：验证 NameServer/Broker 重启后消费位点可恢复
- 步骤：TC-DEP-04c 环境生产 100 条 → 消费 30 条并提交位点 → `docker restart tc-dep-rmq-broker` → 继续消费
- 通过标准：重启后从提交位点继续消费；总消费数 = 100；无重复消费（启用幂等去重时）
- 诚实标注：未在本项目 CI 实际运行

**TC-DEP-15c Redpanda 快照恢复**:

- 目的：验证 Redpanda 数据目录保留时容器重建可恢复
- 步骤：单节点带命名卷启动 → 生产 100 条 → `docker rm -f tc-dep-redpanda` → 用同一数据卷重建容器 → 消费
- 通过标准：重建后 `rpk topic list` 可见原 topic；消费数 ≥100（按至少一次语义报告）
- 诚实标注：未在本项目 CI 实际运行

## T.02.6 部署测试总检查清单

- [ ] TC-DEP-01~04/04c/04d 六系统部署用例 PASS（或 SKIP 并记录原因）
- [ ] TC-DEP-05~08/08c/08d 配置静态校验全过（无环境也必须过）
- [ ] TC-DEP-09 升级预检无 BLOCKER
- [ ] TC-DEP-10/11b/11c 滚动/小版本升级期间收发不中断
- [ ] TC-DEP-12~15/15b/15c 备份恢复用例通过，RPO/RTO 实测值写入报告
- [ ] 失败用例已按 TEST-05 分类建档（产品缺陷/用例缺陷/环境）
- [ ] 结果记入批次报告并同步 PROJECT_STATUS 质量节

用例执行顺序与环境复用矩阵（减少环境起停开销）：

| 批次 | 用例 | 环境 | 说明 |
| ------ | ------ | ------ | ------ |
| A | TC-DEP-05~08/08c/08d（静态） | 无 | 任何机器先跑；无模板时 SKIP |
| B | TC-DEP-01/09/10/11 | compose-kafka | 同环境串行 |
| C | TC-DEP-02 | compose-nats | 独立 |
| D | TC-DEP-03 | compose-rabbitmq | 独立 |
| E | TC-DEP-04c/11b/15b | docker-rocketmq | 单机 NameServer+Broker+Proxy |
| F | TC-DEP-04d/11c/15c | docker-redpanda | 单节点 rpk |
| G | TC-DEP-12~15 | 对应系统环境按 B/C/D/E/F 复用 | 恢复类需干净数据面 |

执行记录：每用例完成后在批次报告中登记 PASS/FAIL/SKIP 与实测输出摘要；FAIL 立即建档（TEST-05），禁止"先跑完全部再回头补档"。

## T.02.7 参考来源

- 项目内：[config-templates/](../../topics/config-templates/)（compose 与参数模板）、[scripts/deploy-kafka.sh](../../topics/scripts/deploy-kafka.sh)、[scripts/validate-config.sh](../../topics/scripts/validate-config.sh)、[scripts/upgrade-check.sh](../../topics/scripts/upgrade-check.sh)、[scripts/backup-verify.sh](../../topics/scripts/backup-verify.sh)、[03-01 部署架构模式矩阵](../../topics/03-架构与运维实践/03-01-部署架构模式矩阵.md)、[03-27 版本升级指南](../../topics/03-架构与运维实践/03-27-版本升级指南.md)
- 外部：[Kafka 官方升级文档](https://kafka.apache.org/documentation/#upgrade)、[RabbitMQ 备份文档](https://www.rabbitmq.com/docs/backup)、[NATS JetStream 备份](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/backup_restore)、[RocketMQ Docker 快速开始](https://rocketmq.apache.org/docs/quickStart/02quickstartWithDocker/)、[Redpanda Self-Managed Quickstart](https://docs.redpanda.com/streaming/current/get-started/quick-start/)

---

**最后更新**: 2026-11-18
