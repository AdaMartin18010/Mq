# 消息队列术语表（Glossary）

## A

**ACK (Acknowledgment)** - 确认机制

- **Kafka**: acks=0/1/-1，控制消息确认级别
- **MQTT**: PUBACK/PUBREC/PUBCOMP，QoS确认报文
- **NATS**: Consumer ACK，JetStream消息确认

**AP系统 (Availability-Partition tolerance)** - 可用性-分区容忍系统

- **NATS Core**: AP系统，优先可用性和性能
- **MQTT**: AP系统，主从模式保证可用性

**At-Least-Once** - 至少一次投递

- **Kafka**: acks=1，保证消息至少送达一次
- **MQTT**: QoS 1，至少一次投递
- **NATS JetStream**: 默认投递语义

**At-Most-Once** - 最多一次投递

- **Kafka**: acks=0，不保证投递
- **MQTT**: QoS 0，最多一次投递
- **NATS Core**: 默认投递语义

## B

**Broker** - 消息代理

- **Kafka**: Broker节点，存储Partition
- **MQTT**: Broker服务器，管理连接和路由
- **NATS**: Server节点，路由消息
- **Pulsar**: Broker节点（无状态），负责消息路由和负载均衡

## C

**CAP定理** - 一致性、可用性、分区容忍性

- **Kafka**: CP系统（一致性+分区容忍）
- **NATS Core**: AP系统（可用性+分区容忍）
- **NATS JetStream**: CP系统（Raft共识）
- **Pulsar**: CP系统（BookKeeper Quorum共识）

**Consumer** - 消费者

- **Kafka**: Consumer从Broker拉取消息
- **MQTT**: Subscriber订阅Topic接收消息
- **NATS**: Subscriber订阅Subject接收消息
- **Pulsar**: Consumer订阅Topic，支持Exclusive/Shared/Failover/Key_Shared四种订阅模式

**Consumer Group** - 消费者组

- **Kafka**: 多个Consumer组成Group，实现负载均衡
- **MQTT**: 无Consumer Group概念
- **NATS**: Queue Group实现类似功能

**CP系统 (Consistency-Partition tolerance)** - 一致性-分区容忍系统

- **Kafka**: CP系统，ISR机制保证一致性
- **NATS JetStream**: CP系统，Raft共识算法
- **Pulsar**: CP系统，BookKeeper Quorum共识算法

## D

**Dead Letter Queue (DLQ)** - 死信队列

- 处理失败消息的队列
- Kafka通过Consumer异常处理实现
- NATS JetStream支持消息重试和DLQ
- **Pulsar**: 原生支持死信队列，自动处理失败消息

## E

**Exactly-Once** - 恰好一次投递

- **Kafka**: acks=-1 + 幂等性 + 事务
- **MQTT**: QoS 2，四步握手保证
- **NATS JetStream**: 事务模式支持
- **Pulsar**: 事务模式支持，保证恰好一次投递

## F

**Follower** - 跟随者

- **Kafka**: Partition的副本节点，从Leader同步数据
- **MQTT**: 无Follower概念
- **NATS**: 所有节点对等，无主从之分

## G

**Gossip协议** -  gossip协议

- **NATS**: 用于集群自动发现和状态同步
- 无中心化，节点间相互通信

## H

**High Watermark (HW)** - 高水位线

- **Kafka**: Consumer只能消费到HW之前的消息
- 保证已提交消息的可见性

**Hot Standby** - 热备

- **MQTT**: 主从模式中的备用Broker
- 主Broker故障时自动切换

## I

**ISR (In-Sync Replicas)** - 同步副本集合

- **Kafka**: 与Leader保持同步的副本集合
- 用于保证数据一致性和可用性

## J

**JetStream** - NATS持久化流处理

- 基于Raft共识算法
- 提供流存储和消息重放功能

## K

**KeepAlive** - 保活机制

- **MQTT**: 心跳检测，保持连接活跃
- **NATS**: 连接心跳，检测连接状态

## L

**Leader** - 领导者

- **Kafka**: Partition的主节点，处理读写请求
- **NATS JetStream**: Raft算法选出的Leader

**LWT (Last Will Testament)** - 遗嘱消息

- **MQTT**: 设备异常断开时自动发布的消息
- 用于设备状态监控

## M

**Message Queue** - 消息队列

- 异步消息传递机制
- 解耦生产者和消费者

**MirrorMaker** - Kafka镜像工具

- 用于Kafka集群间数据复制
- 支持跨数据中心同步

## N

**NATS** - 云原生消息系统

- CNCF项目
- 简单、高性能、云原生友好

## O

**Offset** - 偏移量

- **Kafka**: 消息在Partition中的位置
- 用于消息定位和消费进度管理

**OSR (Out-of-Sync Replicas)** - 不同步副本

- **Kafka**: 与Leader不同步的副本
- 可能因网络延迟或节点故障导致

## P

**Partition** - 分区

- **Kafka**: Topic的物理分片
- **Pulsar**: Topic的逻辑分片（Ledger），自动管理
- 实现并行处理和水平扩展

**Producer** - 生产者

- **Kafka**: 发送消息到Broker
- **MQTT**: Publisher发布消息到Topic
- **NATS**: Publisher发布消息到Subject
- **Pulsar**: Producer发送消息到Topic，支持批量发送和压缩

**Pub/Sub** - 发布-订阅模式

- 消息发布者与订阅者解耦
- 支持一对多消息分发

## Q

**QoS (Quality of Service)** - 服务质量

- **MQTT**: QoS 0/1/2，不同可靠性级别
- QoS 0: 最多一次
- QoS 1: 至少一次
- QoS 2: 恰好一次

**Queue Group** - 队列组

- **NATS**: 多个Subscriber组成队列组
- 实现负载均衡，消息只投递给一个Subscriber

## R

**Raft** - Raft共识算法

- **NATS JetStream**: 用于保证数据一致性
- 分布式一致性算法

**Rebalance** - 重平衡

- **Kafka**: Consumer Group重新分配Partition
- 触发条件：Consumer加入/离开、Partition变化

**Retention** - 保留策略

- **Kafka**: 消息保留时间或大小限制
- **NATS JetStream**: Stream保留策略

## S

**Segment** - 段文件

- **Kafka**: Log文件按大小或时间切分
- 便于管理和清理

**Subject** - 主题

- **NATS**: 消息路由的主题名称
- 支持通配符匹配

**Subscription** - 订阅

- **MQTT**: 订阅Topic接收消息
- **NATS**: 订阅Subject接收消息

## T

**Topic** - 主题

- **Kafka**: 消息的逻辑分类
- **MQTT**: 消息的主题名称，支持层级结构

**Transaction** - 事务

- **Kafka**: 支持跨Partition事务
- **NATS JetStream**: 支持事务模式

## U

**Under-Replicated** - 欠副本

- **Kafka**: Partition副本数不足
- 影响可用性和数据安全性

## V

**Version** - 版本

- **MQTT**: 3.1.1 / 5.0
- **Kafka**: 持续演进，支持KRaft模式
- **NATS**: 持续更新，向后兼容

## W

**Wildcard** - 通配符

- **MQTT**: `+` (单层) / `#` (多层)
- **NATS**: `*` (单层) / `>` (多层)

## Z

**ZooKeeper** - 协调服务

- **Kafka**: 元数据管理和Controller选举
- Kafka 3.0+支持KRaft模式，逐步替代ZK

---

**参考文档**:

- [Kafka术语表](https://kafka.apache.org/documentation/#terminology)
- [MQTT规范](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [NATS文档](https://docs.nats.io/)
