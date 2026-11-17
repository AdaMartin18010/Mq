# 基准结果记录模板

> **本文档定位**: Testing/fixtures 夹具层结果模板，登记一次 OpenMessaging Benchmark 实测的上下文、结果、置信区间与回灌建议。复制时改名为 `benchmark-result-<系统>-<日期>.md`，并替换所有 `SAMPLE` 占位数据。
> **警告**: 下文所有 `SAMPLE` 数值均为示意性占位，**不得**作为真实性能数字引用。

---

## 1. 环境段

| 类别 | 组件 | 配置 / 版本 |
| ------ | ------ | ------------- |
| 硬件 | CPU | SAMPLE: Intel Xeon Gold 6248R @ 3.0GHz，24 核 × 2 路 |
| 硬件 | 内存 | SAMPLE: 256GB DDR4 2933MHz |
| 硬件 | 磁盘 | SAMPLE: NVMe SSD 3.2TB × 2，RAID-0，XFS |
| 硬件 | 网络 | SAMPLE: 25Gbps RoCEv2，节点间延迟 <0.2ms |
| 硬件 | 拓扑 | SAMPLE: 3 代理节点 + 3 客户端 worker 节点 |
| 软件 | 被测系统 | SAMPLE: Apache Kafka 3.9.0 |
| 软件 | OMB | SAMPLE: openmessaging/benchmark@a1b2c3d4 |
| 软件 | JDK / Maven | SAMPLE: OpenJDK 17.0.12 / Maven 3.9.9 |
| 软件 | OS / 容器 | SAMPLE: Rocky Linux 9.4 / Docker 27.3.1 |
| 环境 | 环境 ID | SAMPLE: E2-omb-2026-11-18 |
| 环境 | 任务包/用例 | SAMPLE: weekly-omb-2026-11-18 / TC-BENCH-02 |
| 环境 | 测试日期 | SAMPLE: 2026-11-18 |

---

## 2. Workload 与驱动配置段

```yaml
# workload（SAMPLE）
name: SAMPLE-1KB-1topic-6partition
topics: 1
partitionsPerTopic: 6
messageSize: 1024
producersPerTopic: 3
consumerPerSubscription: 3
producerRate: 500000
testDurationMinutes: 10
warmupDurationMinutes: 2

# driver-kafka/kafka.yaml 关键段（SAMPLE）
bootstrap.servers: kafka-1:9092,kafka-2:9092,kafka-3:9092
topicConfig: | min.insync.replicas=2; replication.factor=3
producerConfig: | acks=all; batch.size=32768; linger.ms=10; compression.type=snappy
```

---

## 3. 结果表（吞吐 / 延迟分位数）

> 下表数值均为 SAMPLE 占位数据，仅展示填写格式。

| 运行编号 | 目标速率 (msg/s) | 实际发布速率 (msg/s) | 实际消费速率 (msg/s) | P50 (ms) | P95 (ms) | P99 (ms) | P99.9 (ms) | 错误率 |
| ---------- | ------------------ | ---------------------- | ---------------------- | ---------- | ---------- | ---------- | ------------ | -------- |
| SAMPLE-1 | 500,000 | 498,200 | 497,800 | 2.1 | 8.5 | 18.3 | 45.2 | 0.00% |
| SAMPLE-2 | 500,000 | 499,100 | 498,900 | 2.0 | 8.2 | 17.8 | 42.1 | 0.00% |
| SAMPLE-3 | 500,000 | 497,900 | 498,100 | 2.2 | 8.9 | 19.1 | 48.7 | 0.00% |

---

## 4. 置信区间说明

基于 3 次独立运行（含预热，正式采样 10 分钟），公式 `μ ± t(0.975,2) * σ / sqrt(3)`，t ≈ 4.303：

| 指标 | 均值 μ | 标准差 σ | 95% 置信区间 | 变异系数 |
| ------ | -------- | ---------- | -------------- | ---------- |
| 实际发布速率 (msg/s) | SAMPLE: 498,400 | 640 | 498,400 ± 1,590 | 0.13% |
| P99 延迟 (ms) | SAMPLE: 18.4 | 0.66 | 18.4 ± 1.6 | 3.6% |
| P99.9 延迟 (ms) | SAMPLE: 45.3 | 3.30 | 45.3 ± 8.2 | 7.3% |

SAMPLE 结论：P99 延迟 95% CI 宽度小于均值 10%，结果可接受；P99.9 变异较大，如需更精确建议增加至 5 次以上运行。

---

## 5. 复现命令

```bash
# 预检
docker compose version && java -version && mvn -version

# 构建 OMB
git clone https://github.com/openmessaging/benchmark.git
cd benchmark && git checkout a1b2c3d4 && mvn clean package -DskipTests

# 启动并执行
docker compose -f driver-kafka/deploy/docker-compose.yaml up -d
bin/benchmark \
  --drivers driver-kafka/kafka.yaml \
  --workers http://worker-1:8080,http://worker-2:8080,http://worker-3:8080 \
  --output results/SAMPLE-kafka-2026-11-18.json \
  workloads/SAMPLE-1KB-1topic-6partition.yaml

# 归档
cp results/SAMPLE-kafka-2026-11-18.json \
   results/weekly-omb-2026-11-18/E2-TC-BENCH-02-omb-result.json
```

---

## 6. 结论与文档回灌建议

**结论（SAMPLE）**: 在 E2 环境、Kafka 3.9.0、3 副本 `acks=all`、1KB 消息、6 分区、3 生产者 3 消费者条件下，可持续吞吐约 **498,000 msg/s**，P99 端到端延迟约 **18ms**；未观察到消息丢失或错误率上升。

**文档回灌建议**:

| 目标文档 | 可替换的【估算】项 | 引用格式 |
| ---------- | -------------------- | ---------- |
| [01-18 性能基准测试对比](../../topics/01-基础概念与对比分析/01-18-性能基准测试对比.md) | Kafka 1KB 吞吐 / P99 延迟 | 【论证：OMB 实测，openmessaging/benchmark@a1b2c3d4，workload/SAMPLE-1KB-1topic-6partition.yaml，E2-omb-2026-11-18，2026-11-18】 |

回灌前确认：目标文档持久化参数与本结果一致；已走 hermes L3 审批并登记 TEST-05 双向修正登记表；已运行 `./topics/scripts/doc-self-check.sh full` 检查联动引用。

---

**最后更新**: 2026-11-18
