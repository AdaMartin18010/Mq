# T.02 运维部署测试用例

> **本文档定位**：部署层的可执行用例库——安装部署、配置校验、升级回滚、备份恢复四类（TC-DEP-01~16）。设计论证见 02 系列与 03-01；本文档只给"命令 + 预期输出 + 通过标准"。

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
| `scripts/deploy-*.sh`、`validate-config.sh`、`upgrade-check.sh`、`backup-verify.sh` | 执行器 |

> 注：compose 模板沿用项目现有镜像（cp-kafka 为 ZooKeeper 模式）；KRaft 模板化属后续治理项，用例命令以服务名 `kafka-1` 为准。

```bash
# 环境预检（任一不满足则运行类用例全部 SKIP）
docker info >/dev/null 2>&1 || { echo "SKIP: 无 docker"; exit 0; }
docker compose version >/dev/null 2>&1 || { echo "SKIP: 无 compose v2"; exit 0; }
df -h /var/lib/docker | awk 'NR==2{exit !($4+0>10)}'  # 磁盘余量 >10G
```

## T.02.2 安装部署用例

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

**TC-DEP-01 Kafka 多 broker 部署（compose-kafka）**

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

**TC-DEP-02 NATS + JetStream 部署**

- 步骤：`docker compose -f topics/config-templates/docker-compose-nats.yml up -d`；`nats server check jetstream -s nats://localhost:4222`
- 通过标准：`nats stream add TC_DEP_02 --subjects tc.dep.02 --storage file --defaults` 成功；`nats pub tc.dep.02 hello` + `nats sub` 往返成功

**TC-DEP-03 RabbitMQ quorum 队列部署**

- 步骤：`docker compose -f topics/config-templates/docker-compose-rabbitmq.yml up -d`；`rabbitmqctl await_startup`
- 通过标准：`rabbitmqadmin declare queue name=tc-dep-03 queue_type=quorum` 成功；`rabbitmq-perf-test -x 1 -y 1 -u tc-dep-03 -z 10` 无错误

**TC-DEP-04 多系统共存部署（compose-all）**

- 目的：验证 `docker-compose-all.yml` 端口/网络无冲突
- 通过标准：`docker compose -f topics/config-templates/docker-compose-all.yml config -q` 退出码 0；全部服务 healthy

**TC-DEP-04b Redis 与 MQTT 部署（compose-all 单服务提取）**

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

| 用例 | 系统 | 核心验证点 | 通过标准 |
| ------ | ------ | ----------- | ---------- |
| TC-DEP-01 | Kafka | KRaft 启动/topic/收发 | 收发往返成功，日志无 ERROR |
| TC-DEP-02 | NATS | JetStream 流创建/收发 | stream info 显示 Ready |
| TC-DEP-03 | RabbitMQ | quorum 队列声明/收发 | perf-test 0 错误 |
| TC-DEP-04 | 全系统 | 端口/网络冲突 | `config -q` 通过 + healthy |

## T.02.3 配置校验用例

**TC-DEP-05 Kafka server.properties 静态校验（无 Docker 可执行）**

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

**TC-DEP-06 客户端配置校验**

- 断言：`kafka-producer-config.properties` 中 `acks=all`、`enable.idempotence=true`；`kafka-consumer-config.properties` 中 `isolation.level=read_committed`（事务场景）或 `read_uncommitted`（非事务场景，文档须注明）
- 通过标准：关键参数与 03-59 测试策略表中"消息不丢不重"要求一致

| 用例 | 对象 | 关键断言 | 依据 |
| ------ | ------ | ---------- | ------ |
| TC-DEP-05 | Kafka server | RF≥2、min.insync≥1、unclean=false | 01-13/03-16 |
| TC-DEP-06 | Kafka client | acks=all、幂等开启、隔离级别注明 | 03-59 |
| TC-DEP-07 | RabbitMQ | `cluster_partition_handling`、quorum 默认 | 01-15 |
| TC-DEP-08 | NATS | JetStream max_memory_store/max_file_store 上限 | 01-26 |

## T.02.4 升级与回滚用例

**TC-DEP-09 升级前检查（静态，无环境可执行）**

- 步骤：`./topics/scripts/upgrade-check.sh`（项目已有脚本）
- 通过标准：输出无 BLOCKER 项；目标版本与当前版本的 log message format 兼容（Kafka 跨 major 必须空升级窗口）

**TC-DEP-10 Kafka 滚动升级（4.x 小版本）**

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

**TC-DEP-11 配置热更新验证**

- 步骤：修改 `kafka-server.properties.template` 的 `log.retention.hours` → 滚动重启 → `kafka-configs.sh --describe --entity-type brokers`
- 通过标准：新值生效且旧 segment 按新策略清理

| 用例 | 场景 | 回滚要求 | 通过标准 |
| ------ | ------ | ---------- | ---------- |
| TC-DEP-09 | 升级预检 | 无（只读） | 无 BLOCKER |
| TC-DEP-10 | 小版本滚动升级 | 镜像 tag 回退 + URP=0 | 收发不间断 |
| TC-DEP-11 | 热更新 | 配置回退重启 | 新参数生效 |

## T.02.5 备份恢复用例

**TC-DEP-12 Kafka 主题元数据备份/恢复**

- 步骤：`./topics/scripts/backup-all.sh kafka` → 删除测试 topic → `./topics/scripts/restore-all.sh kafka`
- 通过标准：被删 topic 恢复且分区数/RF 一致；数据面按"至少一次"语义校验（备份点后的消息允许缺失，须在报告中声明 RPO）

**TC-DEP-13 NATS JetStream 流快照恢复**

- 步骤：`nats stream snapshot TC_DEP_02 --file /tmp/backup.tar` → `nats stream rm TC_DEP_02` → 按快照重建
- 通过标准：重建后 `nats stream info` 的 Messages/Bytes 与快照一致

**TC-DEP-14 RabbitMQ quorum 队列数据恢复**

- 步骤：声明持久化 quorum 队列 → 发 1000 条 → `rabbitmqctl stop_app` 单节点 → 重启 → 消费计数
- 通过标准：消费到 1000 条；队列 leader 重新选举完成时间 < 30s【估算】

**TC-DEP-15 备份介质可用性验证**

- 步骤：`./topics/scripts/backup-verify.sh`（校验备份文件完整性/可解压/含元数据）
- 通过标准：退出码 0；报告含备份大小、时间戳、校验和

## T.02.6 部署测试总检查清单

- [ ] TC-DEP-01~04 四系统部署用例 PASS（或 SKIP 并记录原因）
- [ ] TC-DEP-05~08 配置静态校验全过（无环境也必须过）
- [ ] TC-DEP-09 升级预检无 BLOCKER
- [ ] TC-DEP-10 滚动升级期间 URP=0、消费无 STUCK
- [ ] TC-DEP-12~15 备份恢复用例通过，RPO/RTO 实测值写入报告
- [ ] 失败用例已按 TEST-05 分类建档（产品缺陷/用例缺陷/环境）
- [ ] 结果记入批次报告并同步 PROJECT_STATUS 质量节

用例执行顺序与环境复用矩阵（减少环境起停开销）：

| 批次 | 用例 | 环境 | 说明 |
| ------ | ------ | ------ | ------ |
| A | TC-DEP-05~08（静态） | 无 | 任何机器先跑 |
| B | TC-DEP-01/09/10/11 | compose-kafka | 同环境串行 |
| C | TC-DEP-02 | compose-nats | 独立 |
| D | TC-DEP-03 | compose-rabbitmq | 独立 |
| E | TC-DEP-12~15 | 对应系统环境按 B/C/D 复用 | 恢复类需干净数据面 |

执行记录：每用例完成后在批次报告中登记 PASS/FAIL/SKIP 与实测输出摘要；FAIL 立即建档（TEST-05），禁止"先跑完全部再回头补档"。

## T.02.7 参考来源

- 项目内：[config-templates/](../config-templates/)（compose 与参数模板）、[scripts/deploy-kafka.sh](../scripts/deploy-kafka.sh)、[scripts/validate-config.sh](../scripts/validate-config.sh)、[scripts/upgrade-check.sh](../scripts/upgrade-check.sh)、[scripts/backup-verify.sh](../scripts/backup-verify.sh)、[03-01 部署架构模式矩阵](../03-架构与运维实践/03-01-部署架构模式矩阵.md)、[03-27 版本升级指南](../03-架构与运维实践/03-27-版本升级指南.md)
- 外部：[Kafka 官方升级文档](https://kafka.apache.org/documentation/#upgrade)、[RabbitMQ 备份文档](https://www.rabbitmq.com/docs/backup)、[NATS JetStream 备份](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/backup_restore)

---

**最后更新**: 2026-11-17
