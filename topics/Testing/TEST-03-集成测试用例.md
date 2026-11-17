# T.03 集成测试用例

> **本文档定位**：集成层（L2/L3）可执行用例库——契约兼容、端到端投递语义、容器化集成、网络故障注入、多语言示例回归（TC-INT-01~12）。设计论证见 02-43，通用方法参数见 03-59。

## 目录

- [T.03 集成测试用例](#t03-集成测试用例)
  - [目录](#目录)
  - [T.03.1 范围与策略](#t031-范围与策略)
  - [T.03.2 契约与序列化用例](#t032-契约与序列化用例)
  - [T.03.3 端到端投递语义用例](#t033-端到端投递语义用例)
  - [T.03.4 容器化集成用例（Testcontainers）](#t034-容器化集成用例testcontainers)
  - [T.03.5 网络故障注入用例（Toxiproxy）](#t035-网络故障注入用例toxiproxy)
  - [T.03.6 多语言示例回归用例](#t036-多语言示例回归用例)
  - [T.03.7 集成测试检查清单](#t037-集成测试检查清单)
  - [T.03.8 参考来源](#t038-参考来源)

---

## T.03.1 范围与策略

集成测试验证"消息队列 × 业务系统 × 外部组件"的协同正确性，按消息旅程的关键语义设用例：

| 语义 | 风险 | 对应用例 |
| ------ | ------ | ---------- |
| 不丢 | Broker 宕机/确认丢失 | TC-INT-03/05 |
| 不重 | 重试/重平衡导致重复 | TC-INT-04 |
| 顺序 | 分区键/单队列序 | TC-INT-06 |
| 事务 | 发送端事务+消费端隔离 | TC-INT-07 |
| 边界 | 大消息/空消息/非法字符 | TC-INT-08 |
| 兼容 | Schema 演进 | TC-INT-01/02 |
| 韧性 | 下游慢/断连 | TC-INT-09~11 |

环境与数据规则（沿用 03-59）：`test.environment.isolated=true`；基准消息量 `test.performance.benchmark.messages.count=100000`；结束清理 `test.environment.cleanup.enabled=true`。

## T.03.2 契约与序列化用例

**TC-INT-01 Schema 兼容模式校验**

- 目的：Avro/Protobuf/JSON Schema 演进不破坏消费端
- 步骤（以 Kafka Schema Registry 为例）：

```bash
# 注册 v1 后，以 BACKWARD 模式注册 v2（仅加可选字段）
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data '{"schema": "<v2 avro schema>"}' \
  http://localhost:8081/subjects/orders-value/versions
# 兼容校验失败时返回 409；通过时返回 {"id": <n>}
```

- 通过标准：加可选字段/删字段的合法演进通过；改字段类型被 409 拒绝

**TC-INT-02 多协议消息互通**

- 步骤：CloudEvents 结构消息经 Kafka 生产 → MQTT 桥接消费（对应 01-30/02-34 桥接模式）
- 通过标准：必需属性（id/source/type/specversion）无丢失；时间戳精度降级时文档注明

| 用例 | 演进操作 | 预期 |
| ------ | ---------- | ------ |
| TC-INT-01a | 加 optional 字段 | 通过 |
| TC-INT-01b | 删字段（BACKWARD） | 通过 |
| TC-INT-01c | 改字段类型 | 409 拒绝 |
| TC-INT-02 | CloudEvents 跨协议 | 必需属性保留 |

## T.03.3 端到端投递语义用例

**TC-INT-03 不丢验证（acks=all + min.insync.replicas=2）**

- 步骤：生产者 `acks=all` 发 10,000 条 → 中途 `kill -9` 一个 broker → 统计消费数
- 通过标准：消费数 = 10,000（已提交消息不丢失【论证：Kafka 副本协议保证】）；故障期间发送失败但可重试成功

**TC-INT-04 不重验证（幂等+事务）**

- 步骤：消费者处理中途崩溃 → 重平衡后重新消费 → 统计业务副作用次数
- 通过标准：开启幂等消费（去重表/幂等键，见 02-25）时副作用恰好一次；未开启时报告中注明"至少一次，重复率实测值"

**TC-INT-05 重试风暴观测**

- 步骤：下游注入 500ms 延迟 → 生产者重试 → 观测有效吞吐与重试放大系数
- 通过标准：重试放大系数实测值记录并与 α≈0.3【估算】比对；不触发 broker 端 `delivery.timeout.ms` 大面积超时

**TC-INT-06 顺序保证**

- 步骤：同 key 发 1..1000 → 单分区消费校验顺序
- 通过标准：单分区内严格递增；跨分区文档注明"分区有序，全局无序"

**TC-INT-07 事务端到端**

- 步骤：`initTransactions → beginTransaction → send ×2 → sendOffsetsToTransaction → commit` → 消费端 `isolation.level=read_committed`
- 通过标准：中止事务消息对读已提交消费者不可见；`__consumer_offsets` 与数据面一致

**TC-INT-08 消息边界**

- 步骤：1B 空消息、`max.message.bytes` 临界值 1,048,588B、含 `\0` 与 UTF-8 四字节字符消息各 10 条
- 通过标准：全部往返且字节级一致；超限消息按预期进 DLQ 或拒绝并记录

## T.03.4 容器化集成用例（Testcontainers）

**TC-INT-09 Kafka 容器化 E2E（Java 示例骨架）**

```java
@Testcontainers
class KafkaE2EIT {
    @Container
    KafkaContainer kafka = new KafkaContainer(
        DockerImageName.parse("apache/kafka-native:latest"));

    @Test
    void sendReceiveRoundTrip() {
        Properties p = new Properties();
        p.put("bootstrap.servers", kafka.getBootstrapServers());
        p.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        p.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        p.put("acks", "all");
        try (Producer<String, String> producer = new KafkaProducer<>(p)) {
            producer.send(new ProducerRecord<>("tc-int-09", "k", "v")).get();
        }
        // 消费端断言收到且仅收到 1 条
    }
}
```

**TC-INT-10 多系统容器编排 E2E**

- 步骤：一次 JUnit/pytest 会话内同时起 KafkaContainer + RabbitMQ 容器（testcontainers 多模块）→ 桥接转发 100 条 → 双侧计数
- 通过标准：双侧计数相等；容器退出码 0 自动清理

**Python 侧等价用例（testcontainers-python）**：

```python
from testcontainers.kafka import KafkaContainer
with KafkaContainer() as kafka:
    bootstrap = kafka.get_bootstrap_servers()
    # 生产者/消费者往返断言同 TC-INT-09
```

## T.03.5 网络故障注入用例（Toxiproxy）

**TC-INT-11 下游延迟与断连**

```bash
# 起 toxiproxy-server（默认 API :8474），将 9093 代理到 kafka:9092
toxiproxy-cli create kafka -l 0.0.0.0:9093 -u kafka:9092
# 注入 1000ms 延迟
toxiproxy-cli toxic add kafka -t latency -a latency=1000
# 观测：producer 吞吐下降、无消息丢失（acks=all 重试成功）
toxiproxy-cli toxic remove kafka -n latency_downstream
# 注入断连 5s
toxiproxy-cli toxic add kafka -t timeout -a timeout=5000
```

- 通过标准：延迟注入期间无消息丢失（重试补偿）；断连恢复后自动续传；`delivery.timeout.ms=120000` 未触发

| 用例 | 注入 | 预期行为 |
| ------ | ------ | ---------- |
| TC-INT-11a | 延迟 1s | 吞吐降、0 丢失 |
| TC-INT-11b | 超时 5s | 恢复后续传 |
| TC-INT-11c | 带宽限制 100KB/s | 背压生效无 OOM |

## T.03.6 多语言示例回归用例

**TC-INT-12 examples/ 全量冒烟**

- 目的：`topics/examples/` 52 个示例（6 语言 × 各系统）可编译/可运行骨架有效
- 步骤（静态层无环境可跑，运行层需对应 Broker）：

```bash
# 静态编译检查（按语言工具链存在性 SKIP）
for f in topics/examples/*.go; do go vet ./"$f" 2>/dev/null || echo "FAIL $f"; done
for f in topics/examples/*.py; do python -m py_compile "$f" || echo "FAIL $f"; done
# 运行层：对应 compose 环境起后逐示例跑通生产/消费
```

- 通过标准：静态层 0 FAIL；运行层每系统至少一个语言示例完成收发往返

## T.03.7 集成测试检查清单

- [ ] TC-INT-01 兼容矩阵三种操作结果符合预期
- [ ] TC-INT-03/04 不丢/不重语义有实测数字（非"应该没问题"）
- [ ] TC-INT-05 重试放大系数实测值已记录
- [ ] TC-INT-07 事务可见性验证含"读未提交可见、读已提交不可见"双向断言
- [ ] TC-INT-09/10 容器化用例可重复执行（无端口/状态泄漏）
- [ ] TC-INT-11 故障注入有恢复步骤且执行了恢复验证
- [ ] TC-INT-12 静态层 0 FAIL，运行层 SKIP 项有原因记录
- [ ] 失败项按 TEST-05 建档

## T.03.8 参考来源

- [Testcontainers Kafka 模块文档](https://testcontainers-python.readthedocs.io/en/testcontainers-v4.3.0/modules/kafka/README.html)（含 RedpandaContainer）
- [Toxiproxy 故障注入指南（QASkills，2026）](https://qaskills.sh/blog/toxiproxy-fault-injection-testing-guide-2026)
- [Kafka 事务语义（官方设计文档）](https://kafka.apache.org/documentation/#semantics)
- 项目内：[02-25 消息幂等性设计](../02-场景驱动架构设计/02-25-消息幂等性设计.md)、[02-43 消息测试设计](../02-场景驱动架构设计/02-43-消息测试设计.md)、[03-59 消息测试实践指南](../03-架构与运维实践/03-59-消息测试实践指南.md)、[examples/](../examples/)

---

**最后更新**: 2026-11-17
