# T.04 集群测试验证

> **本文档定位**：集群/分布式层可执行用例库——拓扑故障、一致性验证、混沌编排、集群级性能与恢复指标（TC-CLU-01~10、06b/06c、07b/07c）。与 03-09 集群管理、03-10 K8s 部署、04-04 混沌工程互链。

## 目录

- [T.04 集群测试验证](#t04-集群测试验证)
  - [目录](#目录)
  - [T.04.1 范围与拓扑](#t041-范围与拓扑)
  - [T.04.2 拓扑故障用例](#t042-拓扑故障用例)
  - [T.04.3 一致性验证方法](#t043-一致性验证方法)
  - [T.04.4 混沌编排用例](#t044-混沌编排用例)
  - [T.04.5 集群级性能用例](#t045-集群级性能用例)
  - [T.04.6 恢复指标验证（RTO/RPO）](#t046-恢复指标验证rtorpo)
  - [T.04.7 集群测试检查清单](#t047-集群测试检查清单)
  - [T.04.8 参考来源](#t048-参考来源)

---

## T.04.1 范围与拓扑

默认拓扑（docker-compose 多副本扩展；K8s 环境用 03-10 的 Helm/Operator 等价替换命令）：

| 系统 | 测试拓扑 | 副本数 |
| ------ | ---------- | -------- |
| Kafka | KRaft：3 controller + 3 broker | 6 节点 |
| NATS | 3 节点 JetStream 集群（R=3 流） | 3 节点 |
| RabbitMQ | 3 节点 quorum 集群 | 3 节点 |
| RocketMQ | 2 NameServer + 2 Broker（SYNC_MASTER + SLAVE） | 4 节点 |
| Redpanda | 3 节点 Raft 集群 | 3 节点 |

稳态基线（所有 TC-CLU 用例的前提）：持续后台负载 1,000 msg/s、`benchmark.sh` 延迟基线已记录；无 URP/无 under-replicated stream。

## T.04.2 拓扑故障用例

**TC-CLU-01 Broker/节点硬杀死**:

- 步骤：`docker kill -s 9 <kafka-broker2>`（或 `kill -9`）
- 预期：分区 leader 在 `leader.imbalance.check.interval.ms` 周期内转移；`kafka-topics.sh --describe` URP 归零时间 < 30s【估算：与 broker 数/分区数正相关】
- 通过标准：故障期间已提交消息不丢；恢复后集群收敛

**TC-CLU-02 网络分区（脑裂防护）**:

- 步骤：`pumba netem --tc-image gaiadocker/iproute2 partition ...` 或 Chaos Mesh NetworkChaos 将 broker2 与其他节点隔离 60s：

```bash
# docker 环境等价做法：断 broker2 与其他节点的网络（保留客户端通路）
docker network disconnect <net> <kafka-2-container>
sleep 60
docker network connect <net> <kafka-2-container>
```

- 预期：KRaft quorum（多数派）继续可用；隔离节点恢复后自动追赶
- 通过标准：写操作在多数派侧不中断；恢复后无重复 leader 期（日志校验 `kafka-dump-log` 无 epoch 回退）
- 测量点：分区期间的写入成功率、恢复后 ISR 收敛时间（写入报告 T.04.6）

**TC-CLU-03 滚动重启全集群**:

- 步骤：逐节点 `stop → start`，间隔以"该节点 URP=0"为门
- 通过标准：全程消费端到端无错误（测试客户端断言）；总时长 < N × 单节点时长 × 1.2

**TC-CLU-04 扩缩容**:

- 扩容：Kafka 加 broker → `kafka-reassign-partitions.sh` 重分配 → 通过标准：重分配期间生产不中断，完成后负载均衡度（max/min 分区数）< 1.3【估算】
- 缩容：NATS 流 R=3 → R=2（`nats stream edit`）→ 通过标准：消费者无感知，流状态 Ready

```bash
# Kafka 扩容重分配（--generate 生成计划 → 人工核对 → --execute 执行）
kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --generate --topics-to-move-json-file topics.json --broker-list "1,2,3,4" \
  > reassignment-plan.json
kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --execute --reassignment-json-file reassignment-plan.json
# 验证：--verify 全 done；期间 producer 无 TimeoutException
```

**TC-CLU-05 级联故障**:

- 步骤：连续 kill 两个节点（间隔 10s），模拟 04-03 故障传播方程场景
- 通过标准：剩余多数派仍可用（3 节点集群杀 2 个则整体不可用——该用例的"通过"恰为"验证不可用边界并记录"，报告须区分"设计内不可用"与"级联超预期"）

**TC-CLU-06 磁盘写满**:

- 步骤：向 broker 数据盘填充至 95%
- 通过标准：触发 `log.retention` 紧急清理或拒绝写（而非静默损坏）；告警触发；清理后服务恢复

**TC-CLU-06b RocketMQ 主从切换**:

- 目的：验证 SYNC_MASTER 故障后 SLAVE 提升为 master，消息不丢
- 步骤：2M2S 拓扑持续写 → `docker kill -s 9 <master-broker>` → 观测 SLAVE 提升
- 通过标准：主从切换时间 < 30s【估算】；切换期间已刷盘消息不丢；未确认消息在报告中声明
- 诚实标注：未在本项目 CI 实际运行

**TC-CLU-06c Redpanda 节点硬杀死与重新加入**:

- 目的：验证 Raft 多数派在单节点故障后继续可用，恢复节点自动追赶
- 步骤：3 节点 Redpanda 持续写 → `docker kill -s 9 <redpanda-2>` → 60s 后重启
- 通过标准：2 节点多数派继续服务；恢复节点 `rpk cluster info` 显示 healthy；无 epoch 回退
- 诚实标注：未在本项目 CI 实际运行

| 用例 | 故障 | 关键指标 | 阈值 |
| ------ | ------ | ---------- | ------ |
| TC-CLU-01 | 单点硬杀死 | leader 选举时间 | < 30s【估算】 |
| TC-CLU-02 | 网络分区 60s | 多数派写可用性 | 不中断 |
| TC-CLU-03 | 滚动重启 | 端到端错误数 | 0 |
| TC-CLU-04 | 扩容+再均衡 | 期间生产中断 | 0 次 |
| TC-CLU-05 | 双杀级联 | 不可用边界符合设计 | 记录实测 |
| TC-CLU-06 | 磁盘 95% | 数据完整性 | 无静默损坏 |
| TC-CLU-06b | RocketMQ 主从切换 | 提升耗时/已刷盘消息 | < 30s / 不丢 |
| TC-CLU-06c | Redpanda 单节点故障 | 多数派可用/自动追赶 | 不中断 / healthy |

## T.04.3 一致性验证方法

不自研一致性检验器，采用三层方法：

1. **黑盒队列检验（Jepsen 式）**：多客户端并发 enqueue/dequeue，校验消息既不丢也不重也不乱序（Jepsen queue 工作负载的语义）。Redpanda 的公开分析即采用此法（[jepsen.io/analyses/redpanda-21.10.1](https://jepsen.io/analyses/redpanda-21.10.1)），本项目 Redpanda 结论直接引用该锚点。
2. **形式化模型对照**：KRaft 的一致性论证对照 apache/kafka 仓库的 [TLA+ 规范](https://github.com/apache/kafka/tree/trunk/metadata/src/main/resources/common/metadata)；模型级结论标【定理：引用形式化验证资产】。
3. **运行时不变量断言**：

```bash
# 示例：副本一致性运行时断言（TC-CLU-01 后执行）
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic tc-clu \
  | awk '{print $5}' | sort | uniq -c   # ISR 列：全部分区 ISR 应等于 RF
# 期望输出：每行 ISR 计数 == replication factor，无 under-replicated 标记

# 黑盒队列检验的最小实现（Jepsen 思想简化版）
# 多进程并发入队/出队，按 (enqueue-dequeue) 配对校验：不丢（数量守恒）、
# 不重（唯一 ID）、不乱（单队列 FIFO）
for i in $(seq 1 4); do
  ( for n in $(seq 1 250); do
      id="$i-$n-$(date +%s%N)"
      echo "$id" | kafka-console-producer.sh --bootstrap-server localhost:9092 --topic tc-queue
    done ) &
done; wait
# 消费侧计数应恰为 1000 且 ID 无重复；单分区内消费顺序应等于发送顺序
```

通过标准：三层方法结论无矛盾；与理论预期（04 系列）偏差 > 2 倍时按 TEST-01 T.01.6 规则处理。

**RocketMQ/Redpanda 一致性验证补充**:

- RocketMQ：以主从同步复制（SYNC_MASTER/SYNC_FLUSH）为运行时断言；TC-CLU-06b 后校验 slave 数据与 master 一致；无公开形式化模型引用，结论标【论证】
- Redpanda：一致性结论引用 Jepsen 公开报告（[jepsen.io/analyses/redpanda-21.10.1](https://jepsen.io/analyses/redpanda-21.10.1)，版本锚定 21.10.1）；运行时以 `rpk cluster info` 健康状态和 epoch 单调性为断言

## T.04.4 混沌编排用例

**TC-CLU-07 Chaos Mesh 编排（K8s 环境）**:

```yaml
# chaos/tc-clu-07-broker-kill.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: tc-clu-07-kafka-broker
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app.kubernetes.io/name: kafka
  duration: "60s"
  scheduler:
    cron: "@every 10m"
```

- 步骤：`kubectl apply -f chaos/tc-clu-07-broker-kill.yaml` → 观测稳态指标 60s → `kubectl delete -f ...`
- 通过标准（对齐 04-04 稳态规范）：实验期错误率 < 1%；结束后 5 分钟内吞吐/P99 回到基线 ±10%【估算】

**TC-CLU-08 脚本化混沌（docker 环境，项目 scripts/chaos-test.sh）**:

- 步骤：`./topics/scripts/chaos-test.sh kafka --scenario random_failure --duration 300`
- 通过标准：脚本输出稳态报告；无未恢复故障

**TC-CLU-07b RocketMQ Chaos Mesh 编排（K8s 环境）**:

```yaml
# chaos/tc-clu-07b-rocketmq-broker-kill.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: tc-clu-07b-rocketmq-broker
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app.kubernetes.io/name: rocketmq-broker
  duration: "60s"
```

- 通过标准：TC-CLU-06b 主从切换成功；实验期错误率 < 1%；结束后 5 分钟内吞吐/P99 回到基线 ±10%【估算】
- 诚实标注：YAML 为设计骨架，未在本项目 K8s 环境实际运行

**TC-CLU-07c Redpanda Chaos Mesh 编排（K8s 环境）**:

```yaml
# chaos/tc-clu-07c-redpanda-broker-kill.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: tc-clu-07c-redpanda-broker
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors:
      app.kubernetes.io/name: redpanda
  duration: "60s"
```

- 通过标准：TC-CLU-06c 单节点故障恢复成功；实验期多数派写不中断；结束后 5 分钟内稳态恢复
- 诚实标注：YAML 为设计骨架，未在本项目 K8s 环境实际运行

| 用例 | 编排方式 | 故障类型 | 环境 |
| ------ | ---------- | ---------- | ------ |
| TC-CLU-07 | Chaos Mesh CRD | pod-kill / network / io | K8s |
| TC-CLU-07b | Chaos Mesh CRD | pod-kill | K8s |
| TC-CLU-07c | Chaos Mesh CRD | pod-kill | K8s |
| TC-CLU-08 | chaos-test.sh | 随机杀进程/断网 | docker |

## T.04.5 集群级性能用例

**TC-CLU-09 八系统基准对照**:

- 步骤：`./topics/scripts/benchmark-all.sh`（内部调用 `benchmark.sh <system> 60 10000`，参数与 03-59 一致；新增 RocketMQ/Redpanda 两个系统）
- 通过标准：输出吞吐/延迟报告；与 01-18/01-27/01-28 公开基准量级一致（偏差 > 5 倍时排查环境【估算】）
- RocketMQ 基准：`mqadmin` 或 OpenMessaging Benchmark 连接 NameServer+Broker 集群
- Redpanda 基准：复用 Kafka 客户端（`kafka-producer-perf-test` 或 `rpk topic produce`）连接 Redpanda 集群

**TC-CLU-10 压测至拐点**:

- 步骤：以 03-59 参数 `stress.messages.count=1000000`、`duration=300` 阶梯加压：

| 阶梯 | 速率 (msg/s) | 时长 | 观测重点 |
| ------ | -------------- | ------ | ---------- |
| 1 | 10k | 5min | 基线延迟 |
| 2 | 30k | 5min | 批处理效果 |
| 3 | 50k | 5min | GC/磁盘 IO |
| 4 | 100k | 5min | 拐点定位（吞吐不再增长或 P99 陡增） |

- 通过标准：记录拐点 QPS 与 P99；拐点前无错误率突增；报告含资源四项（CPU/内存/网络/磁盘）

拐点判定口径【论证】：连续两个阶梯的吞吐增长 < 5% 且 P99 增长 > 2 倍，即认定后一阶梯的起点为拐点；报告须给出原始数据表而非仅结论。

## T.04.6 恢复指标验证（RTO/RPO）

| 指标 | 测量方法 | 目标示例【估算，按业务定级替换】 |
| ------ | ---------- | ---------------------------------- |
| RTO | TC-CLU-01 从 kill 到 URP=0 且消费恢复；TC-CLU-06b 主从切换耗时 | ≤ 60s |
| RPO | TC-CLU-06 磁盘故障后最近可恢复点；TC-CLU-06b 已刷盘消息不丢 | ≤ 5min（依赖副本进度） |
| MTTR | 近 30 天故障用例平均恢复时间 | 趋势下降 |
| RTO (Redpanda) | TC-CLU-06c 单节点故障到 `rpk cluster info` healthy | ≤ 60s |

- 通过标准：实测值记录并对比目标；超标项开韧性缺陷单并关联 04-04 反馈回路分析。

## T.04.7 集群测试检查清单

- [ ] 稳态基线已记录（吞吐/延迟/URP），所有用例以此为参照
- [ ] TC-CLU-01~06/06b/06c 逐项执行，不可用边界用例写明"设计内"结论
- [ ] 一致性三层方法（黑盒/形式化/运行时断言）至少覆盖两层；Redpanda 引用 Jepsen 锚点
- [ ] 混沌用例（TC-CLU-07/07b/07c/08）全部执行了恢复验证（非注入完即走）
- [ ] 拐点压测报告含资源四项与拐点 QPS/P99
- [ ] RTO/RPO 实测值写入批次报告
- [ ] 失败项按 TEST-05 建档并回链 04 系列理论参数

> **动态系统论视角**：集群测试中的混沌编排用例不仅验证恢复指标，更是对消息系统韧性的动态演化实验。若需从混沌工程、系统韧性、韧性缺陷反馈回路等角度理解测试设计，参见 [04-04 混沌工程与系统韧性](../../topics/04-动态系统论与演化分析/04-04-混沌工程与系统韧性.md)。

---

## T.04.8 参考来源

- [Jepsen Redpanda 分析（版本锚定引用）](https://jepsen.io/analyses/redpanda-21.10.1)、[jepsen-io/redpanda 仓库](https://github.com/jepsen-io/redpanda)
- [Kafka KRaft TLA+ 规范](https://github.com/apache/kafka/tree/trunk/metadata/src/main/resources/common/metadata)
- [Chaos Mesh 官方文档](https://chaos-mesh.org)
- [RocketMQ 集群部署文档](https://rocketmq.apache.org/docs/deploymentOperations/03deploy/)
- [Redpanda 生产部署文档](https://docs.redpanda.com/streaming/current/deploy/)
- 项目内：[03-09 集群管理与分布式架构](../../topics/03-架构与运维实践/03-09-集群管理与分布式架构.md)、[03-10 Kubernetes 部署实践](../../topics/03-架构与运维实践/03-10-Kubernetes部署实践.md)、[04-03 负载动态响应与故障传播](../../topics/04-动态系统论与演化分析/04-03-负载动态响应与故障传播.md)、[04-04 混沌工程与系统韧性](../../topics/04-动态系统论与演化分析/04-04-混沌工程与系统韧性.md)、[scripts/chaos-test.sh](../../topics/scripts/chaos-test.sh)、[scripts/benchmark-all.sh](../../topics/scripts/benchmark-all.sh)

---

**最后更新**: 2026-11-18
