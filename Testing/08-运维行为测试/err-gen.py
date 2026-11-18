#!/usr/bin/env python3
# 08-运维行为测试 ERR 域错误异常边界矩阵用例生成器
# 维度：7 系统 × 10 错误类；产物：cases/<sys>/<err>/TC-ERR-<SYS>-<ERR>-01.md + registry 追加
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "08-运维行为测试")
REGISTRY = os.path.join(ROOT, "topics", "scripts", "test-registry.tsv")

SYSTEMS = ["KAFKA", "RABBITMQ", "NATS", "PULSAR", "ROCKETMQ", "REDIS", "MQTT"]
ERRORS = [
    "UNKWON_TOPIC", "AUTH_FAIL", "QUOTA_EXCEED", "TIMEOUT", "MALFORMED",
    "PERM_DENIED", "CONN_RESET", "BCKPRESSURE_OVF", "VER_MISMATCH", "RES_EXH"
]

ERR_NAME = {
    "UNKWON_TOPIC": "未知 topic/queue/stream",
    "AUTH_FAIL": "认证/授权失败",
    "QUOTA_EXCEED": "配额超限",
    "TIMEOUT": "客户端超时族",
    "MALFORMED": "畸形消息",
    "PERM_DENIED": "ACL 不足",
    "CONN_RESET": "连接重置/半开连接",
    "BCKPRESSURE_OVF": "背压溢出",
    "VER_MISMATCH": "协议/客户端版本不匹配",
    "RES_EXH": "资源耗尽",
}

DEFAULT_THENS = {
    "UNKWON_TOPIC": [
        "客户端在超时/重试窗口内尝试恢复，持续失败则快速失败",
        "broker 日志或 admin 接口显示资源不存在/404/未知 topic 错误",
    ],
    "AUTH_FAIL": [
        "客户端停止发送并提示认证失败（不重试）",
        "broker 日志/auth 审计记录拒绝事件",
    ],
    "QUOTA_EXCEED": [
        "客户端收到配额超限信号后启用退避/降速，不硬失败",
        "admin/metrics 显示 throttle/reject/配额指标上升",
    ],
    "TIMEOUT": [
        "客户端在超时后按重试策略重试；超过 max retries 则快速失败",
        "metrics 中 request-latency/timeout 计数增加",
    ],
    "MALFORMED": [
        "客户端/ broker 拒绝该条消息并继续处理后续消息（不阻塞）",
        "日志中出现 malformed/corrupt/schema/非法帧错误码",
    ],
    "PERM_DENIED": [
        "客户端收到 ACL 拒绝后停止非法操作并告警（不重试）",
        "authorizer/ACL 审计日志记录 deny 事件",
    ],
    "CONN_RESET": [
        "客户端自动重连并恢复会话/订阅；重连风暴可控",
        "日志记录连接断开与恢复事件",
    ],
    "BCKPRESSURE_OVF": [
        "客户端启用阻塞/降速/丢帧策略，避免 OOM；恢复后自动恢复吞吐量",
        "metrics 显示 pending queue/内存/缓冲满/输出缓冲区超限",
    ],
    "VER_MISMATCH": [
        "客户端按 ApiVersions/协议协商降级或明确报错（不静默失败）",
        "broker 日志记录不支持的协议/客户端版本",
    ],
    "RES_EXH": [
        "broker 进入只读/拒绝新连接；清理资源后自动恢复",
        "metrics 显示 FD/内存/磁盘耗尽报警",
    ],
}

# 每格 specifics：首条 then（含具体错误码），以及行为依据（带 WebSearch 核实来源）
SPECIFIC = {
("KAFKA","UNKWON_TOPIC"): {
    "specific": "客户端收到 `org.apache.kafka.common.errors.UnknownTopicOrPartitionException`（error code 3），`request.timeout.ms` 默认 30000ms 后抛出",
    "src": "Kafka `UNKNOWN_TOPIC_OR_PARTITION` error code 3 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/UNKNOWN_TOPIC_OR_PARTITION/) / [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)",
    "urls": ["https://kafka-options-explorer.conduktor.io/error/UNKNOWN_TOPIC_OR_PARTITION/","https://kafka.apache.org/32/generated/protocol_errors.html"],
},
("KAFKA","AUTH_FAIL"): {
    "specific": "SASL 握手失败抛出 `SaslAuthenticationException`，对应 `SASL_AUTHENTICATION_FAILED`（error code 58）",
    "src": "Kafka `SASL_AUTHENTICATION_FAILED` error code 58 — [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html) / [OneUptime](https://oneuptime.com/blog/post/2026-01-24-kafka-sasl-authentication-exception/view)",
    "urls": ["https://kafka.apache.org/32/generated/protocol_errors.html","https://oneuptime.com/blog/post/2026-01-24-kafka-sasl-authentication-exception/view"],
},
("KAFKA","QUOTA_EXCEED"): {
    "specific": "QuotaManager 在响应中返回 `throttle_time_ms`；硬限制下返回 `POLICY_VIOLATION`（error code 44）",
    "src": "Kafka quota throttle / `POLICY_VIOLATION` error code 44 — [Apache Kafka Protocol Guide](https://kafka.apache.org/26/protocol.html) / [Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)",
    "urls": ["https://kafka.apache.org/26/protocol.html","https://kafka.apache.org/32/generated/protocol_errors.html"],
},
("KAFKA","TIMEOUT"): {
    "specific": "客户端抛出 `TimeoutException` / `RequestTimeoutException`，`request.timeout.ms` 默认 30000ms，`default.api.timeout.ms` 默认 60000ms",
    "src": "Kafka `request.timeout.ms` default 30000ms — [Baeldung](https://www.baeldung.com/java-kafka-timeoutexception) / [Apache Kafka Producer Configs](https://kafka.apache.org/41/configuration/producer-configs/)",
    "urls": ["https://www.baeldung.com/java-kafka-timeoutexception","https://kafka.apache.org/41/configuration/producer-configs/"],
},
("KAFKA","MALFORMED"): {
    "specific": "CRC/size/null key 违规触发 `CorruptRecordException`，对应 `CORRUPT_MESSAGE`（error code 2）",
    "src": "Kafka `CORRUPT_MESSAGE` error code 2 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/CORRUPT_MESSAGE/) / [Apache Kafka Protocol Errors](https://kafka.apache.org/32/generated/protocol_errors.html)",
    "urls": ["https://kafka-options-explorer.conduktor.io/error/CORRUPT_MESSAGE/","https://kafka.apache.org/32/generated/protocol_errors.html"],
},
("KAFKA","PERM_DENIED"): {
    "specific": "ACL 不足返回 `TopicAuthorizationException`（error code 29）/ `GROUP_AUTHORIZATION_FAILED`（30）/ `CLUSTER_AUTHORIZATION_FAILED`（31）",
    "src": "Kafka authorization error codes 29/30/31 — [IBM Troubleshooting](https://www.ibm.com/docs/en/kafka-zos/1.1.0?topic=troubleshooting) / [Apache Kafka Authorization](https://kafka.apache.org/22/security/authorization-and-acls/)",
    "urls": ["https://www.ibm.com/docs/en/kafka-zos/1.1.0?topic=troubleshooting","https://kafka.apache.org/22/security/authorization-and-acls/"],
},
("KAFKA","CONN_RESET"): {
    "specific": "连接被对端关闭时客户端日志出现 `java.io.EOFException` 或 `NetworkException`，broker 日志记录 `Connection with ... disconnected`",
    "src": "Kafka EOFException on connection reset — [Stack Overflow](https://stackoverflow.com/questions/33432027/kafka-error-in-i-o-java-io-eofexception-null) / [Confluent Connectivity](https://www.confluent.io/blog/kafka-client-cannot-connect-to-broker-on-aws-on-docker-etc/)",
    "urls": ["https://stackoverflow.com/questions/33432027/kafka-error-in-i-o-java-io-eofexception-null","https://www.confluent.io/blog/kafka-client-cannot-connect-to-broker-on-aws-on-docker-etc/"],
},
("KAFKA","BCKPRESSURE_OVF"): {
    "specific": "producer buffer.memory 耗尽且超过 `max.block.ms` 时抛出 `BufferExhaustedException`",
    "src": "Kafka `BufferExhaustedException` — [Apache Kafka Javadoc](https://kafka.apache.org/28/javadoc/org/apache/kafka/clients/producer/BufferExhaustedException.html) / [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-bufferexhaustedexception-kafka-producer/view)",
    "urls": ["https://kafka.apache.org/28/javadoc/org/apache/kafka/clients/producer/BufferExhaustedException.html","https://oneuptime.com/blog/post/2026-01-24-fix-bufferexhaustedexception-kafka-producer/view"],
},
("KAFKA","VER_MISMATCH"): {
    "specific": "客户端请求 API version 不被 broker 支持时返回 `UNSUPPORTED_VERSION`（error code 35）",
    "src": "Kafka `UNSUPPORTED_VERSION` error code 35 — [Conduktor](https://kafka-options-explorer.conduktor.io/error/UNSUPPORTED_VERSION/) / [Apache Kafka Upgrade](https://kafka.apache.org/32/getting-started/upgrade/)",
    "urls": ["https://kafka-options-explorer.conduktor.io/error/UNSUPPORTED_VERSION/","https://kafka.apache.org/32/getting-started/upgrade/"],
},
("KAFKA","RES_EXH"): {
    "specific": "broker FD 耗尽时报 `Too many open files`，JVM 堆耗尽时 `OutOfMemoryError`；两者均导致服务降级或重启",
    "src": "Kafka FD / memory exhaustion — [Netdata Too Many Open Files](https://www.netdata.cloud/guides/kafka/kafka-too-many-open-files/) / [Delasport OOM](https://www.delasport.com/when-kafka-runs-out-of-memory-without-running-out-of-memory/)",
    "urls": ["https://www.netdata.cloud/guides/kafka/kafka-too-many-open-files/","https://www.delasport.com/when-kafka-runs-out-of-memory-without-running-out-of-memory/"],
},

("RABBITMQ","UNKWON_TOPIC"): {
    "specific": "向不存在的 queue/exchange 操作时 broker 返回 `NOT_FOUND`（AMQP reply code 404）并关闭 channel",
    "src": "RabbitMQ `NOT_FOUND` 404 — [DevOps AI Toolkit](https://devopsaitoolkit.com/blog/rabbitmq-error-not-found-no-queue-exchange/) / [CSDN 实录](https://wenku.csdn.net/answer/65ofe93zj2)",
    "urls": ["https://devopsaitoolkit.com/blog/rabbitmq-error-not-found-no-queue-exchange/","https://wenku.csdn.net/answer/65ofe93zj2"],
},
("RABBITMQ","AUTH_FAIL"): {
    "specific": "认证失败时 broker 返回 `ACCESS_REFUSED`（AMQP reply code 403）并终止握手",
    "src": "RabbitMQ `ACCESS_REFUSED` 403 — [GitHub Discussion](https://github.com/rabbitmq/rabbitmq-server/discussions/14309) / [OneUptime](https://oneuptime.com/blog/post/2026-01-24-rabbitmq-access-refused-authentication/view)",
    "urls": ["https://github.com/rabbitmq/rabbitmq-server/discussions/14309","https://oneuptime.com/blog/post/2026-01-24-rabbitmq-access-refused-authentication/view"],
},
("RABBITMQ","QUOTA_EXCEED"): {
    "specific": "per-user 连接/通道数或队列长度超限返回 `ConnectionNumExceeded`（530）/ `RESOURCE_LOCKED`（405）/ `channelMax limit reached`",
    "src": "RabbitMQ per-user limits & AMQP error codes — [Alibaba Cloud Error Codes](https://www.alibabacloud.com/help/en/apsaramq-for-rabbitmq/developer-reference/error-codes-returned-when-amqp-methods-are-called) / [CloudAMQP](https://www.cloudamqp.com/blog/connection-limit-per-user-feature/)",
    "urls": ["https://www.alibabacloud.com/help/en/apsaramq-for-rabbitmq/developer-reference/error-codes-returned-when-amqp-methods-are-called","https://www.cloudamqp.com/blog/connection-limit-per-user-feature/"],
},
("RABBITMQ","TIMEOUT"): {
    "specific": "心跳超时或 TCP 握手超时触发 `HEARTBEAT_TIMEOUT` / `Connection reset by peer`，连接被 broker 关闭",
    "src": "RabbitMQ heartbeat/connection reset — [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view) / [GitHub amqplib](https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159)",
    "urls": ["https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view","https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159"],
},
("RABBITMQ","MALFORMED"): {
    "specific": "非法 AMQP 帧触发 `FRAME_ERROR`（AMQP reply code 501），broker 关闭整个连接",
    "src": "RabbitMQ `FRAME_ERROR` 501 — [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-rabbitmq-frame-too-large-errors/view) / [amqplib #757](https://github.com/amqp-node/amqplib/issues/757)",
    "urls": ["https://oneuptime.com/blog/post/2026-01-24-fix-rabbitmq-frame-too-large-errors/view","https://github.com/amqp-node/amqplib/issues/757"],
},
("RABBITMQ","PERM_DENIED"): {
    "specific": "ACL/权限不足返回 `ACCESS_REFUSED`（403）或 `NOT_ALLOWED`（530）",
    "src": "RabbitMQ ACL error codes — [pika spec](https://pika.readthedocs.io/en/stable/_modules/pika/spec.html) / [GitHub Discussion](https://github.com/rabbitmq/rabbitmq-server/discussions/14309)",
    "urls": ["https://pika.readthedocs.io/en/stable/_modules/pika/spec.html","https://github.com/rabbitmq/rabbitmq-server/discussions/14309"],
},
("RABBITMQ","CONN_RESET"): {
    "specific": "TCP 连接被 RST 或 broker 异常关闭，客户端收到 `Socket closed abruptly` / `Connection reset by peer`",
    "src": "RabbitMQ connection reset — [OneUptime](https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view) / [GitHub Azure Functions](https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159)",
    "urls": ["https://oneuptime.com/blog/post/2026-01-24-fix-connection-reset-errors-rabbitmq/view","https://github.com/Azure/azure-functions-rabbitmq-extension/issues/159"],
},
("RABBITMQ","BCKPRESSURE_OVF"): {
    "specific": "内存/磁盘 watermark 触发资源告警，broker 向发布连接发送 `connection.blocked` 帧，publish 挂起",
    "src": "RabbitMQ memory alarm / connection.blocked — [Netdata](https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/) / [DevOps AI Toolkit](https://devopsaitoolkit.com/blog/rabbitmq-error-connection-blocked-notification/)",
    "urls": ["https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/","https://devopsaitoolkit.com/blog/rabbitmq-error-connection-blocked-notification/"],
},
("RABBITMQ","VER_MISMATCH"): {
    "specific": "AMQP 0-9-1/1.0 协议或客户端版本不兼容导致握手失败，返回 `NOT_IMPLEMENTED`（540）或 `protocol version mismatch`",
    "src": "RabbitMQ AMQP version mismatch — [juejin](https://juejin.cn/s/amqp%20protocol%20version%20mismatch%20we%20are%20version%200-9-1) / [pika spec](https://pika.readthedocs.io/en/stable/_modules/pika/spec.html)",
    "urls": ["https://juejin.cn/s/amqp%20protocol%20version%20mismatch%20we%20are%20version%200-9-1","https://pika.readthedocs.io/en/stable/_modules/pika/spec.html"],
},
("RABBITMQ","RES_EXH"): {
    "specific": "Erlang VM 内存超过 watermark 或 FD 耗尽触发资源告警，broker 阻塞发布并记录 `memory resource limit alarm`",
    "src": "RabbitMQ resource exhaustion — [Netdata Memory Alarm](https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/) / [CloudAMQP Monitoring](https://www.cloudamqp.com/blog/monitoring-rabbitmq-in-production/)",
    "urls": ["https://www.netdata.cloud/guides/rabbitmq/rabbitmq-memory-resource-limit-alarm/","https://www.cloudamqp.com/blog/monitoring-rabbitmq-in-production/"],
},

("NATS","UNKWON_TOPIC"): {
    "specific": "JetStream 访问不存在的 stream 返回 `JSStreamNotFoundErr`（err_code 10059，HTTP 404）；Core NATS 无订阅者时请求端收到 `no responders`",
    "src": "NATS JetStream `stream not found` 10059 — [NATS Docs](https://docs.nats.io/reference/2.11/jetstream/errors) / [NATS ADR-1](https://github.com/nats-io/nats-architecture-and-design/blob/main/adr/ADR-1.md)",
    "urls": ["https://docs.nats.io/reference/2.11/jetstream/errors","https://github.com/nats-io/nats-architecture-and-design/blob/main/adr/ADR-1.md"],
},
("NATS","AUTH_FAIL"): {
    "specific": "认证/授权失败时 server 返回 `-ERR 'Authorization Violation'`，客户端进入重连退避",
    "src": "NATS Authorization Violation — [NATS Authorization](https://docs.nats.io/learn/security/authorization) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://docs.nats.io/learn/security/authorization","https://docs.nats.io/reference/system/errors"],
},
("NATS","QUOTA_EXCEED"): {
    "specific": "JetStream 流/账户达到 `maxBytes/maxMsgs/maxConsumers` 限制返回 `insufficient storage resources available`（10047）/ limit exceeded",
    "src": "NATS JetStream resource limits — [NATS JetStream Errors](https://docs.nats.io/reference/2.11/jetstream/errors) / [GitHub #2599](https://github.com/nats-io/nats-server/issues/2599)",
    "urls": ["https://docs.nats.io/reference/2.11/jetstream/errors","https://github.com/nats-io/nats-server/issues/2599"],
},
("NATS","TIMEOUT"): {
    "specific": "Request-Reply 或 JetStream ack 等待超时时客户端收到 `nats: timeout` / `ErrTimeout`",
    "src": "NATS timeout errors — [nats.go pkg](https://pkg.go.dev/github.com/nats-io/nats.go) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://pkg.go.dev/github.com/nats-io/nats.go","https://docs.nats.io/reference/system/errors"],
},
("NATS","MALFORMED"): {
    "specific": "payload 超过 `max_payload` 或协议帧非法时 server 返回 `-ERR 'Maximum Payload Exceeded'` / `ErrMaxPayload`",
    "src": "NATS Maximum Payload Exceeded — [NATS Publish-Subscribe](https://docs.nats.io/learn/core-nats/publish-subscribe) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://docs.nats.io/learn/core-nats/publish-subscribe","https://docs.nats.io/reference/system/errors"],
},
("NATS","PERM_DENIED"): {
    "specific": "发布/订阅无权限主题时 server 返回 `-ERR 'Permissions Violation for Publish/Subscribe to ...'`",
    "src": "NATS Permissions Violation — [NATS Authorization](https://docs.nats.io/learn/security/authorization) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://docs.nats.io/learn/security/authorization","https://docs.nats.io/reference/system/errors"],
},
("NATS","CONN_RESET"): {
    "specific": "连接被 server 或网络重置时客户端日志出现 `ErrConnectionClosed` / `Connection closed`，随后自动重连",
    "src": "NATS connection closed/reconnect — [nats.go pkg](https://pkg.go.dev/github.com/nats-io/nats.go) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://pkg.go.dev/github.com/nats-io/nats.go","https://docs.nats.io/reference/system/errors"],
},
("NATS","BCKPRESSURE_OVF"): {
    "specific": "consumer `maxAckPending` 满或慢消费者被标记为 `slow consumer` 后 server 断开或丢弃消息",
    "src": "NATS slow consumer / maxAckPending — [NATS System Errors](https://docs.nats.io/reference/system/errors) / [NATS Publish-Subscribe](https://docs.nats.io/learn/core-nats/publish-subscribe)",
    "urls": ["https://docs.nats.io/reference/system/errors","https://docs.nats.io/learn/core-nats/publish-subscribe"],
},
("NATS","VER_MISMATCH"): {
    "specific": "旧客户端无法识别 server INFO 中的 `tls_required` 或新协议特性时返回 `SecureConnRequired` / 握手失败",
    "src": "NATS client/server version negotiation — [nats.go pkg](https://pkg.go.dev/github.com/nats-io/nats.go) / [NATS System Errors](https://docs.nats.io/reference/system/errors)",
    "urls": ["https://pkg.go.dev/github.com/nats-io/nats.go","https://docs.nats.io/reference/system/errors"],
},
("NATS","RES_EXH"): {
    "specific": "JetStream 存储目录满或 FD 耗尽返回 `insufficient storage resources available`（10047）/ `Too many open files`",
    "src": "NATS JetStream resource exhaustion — [NATS JetStream Errors](https://docs.nats.io/reference/2.11/jetstream/errors) / [GitHub #2599](https://github.com/nats-io/nats-server/issues/2599)",
    "urls": ["https://docs.nats.io/reference/2.11/jetstream/errors","https://github.com/nats-io/nats-server/issues/2599"],
},

("PULSAR","UNKWON_TOPIC"): {
    "specific": "访问不存在的 topic 时客户端抛出 `TopicDoesNotExistException` / `TopicNotFoundException`（HTTP 404）",
    "src": "Pulsar `TopicNotFoundException` — [Apache Pulsar JIRA PULSAR-20](https://issues.apache.org/jira/browse/PULSAR-20) / [testcontainers-dotnet #1504](https://github.com/testcontainers/testcontainers-dotnet/issues/1504)",
    "urls": ["https://issues.apache.org/jira/browse/PULSAR-20","https://github.com/testcontainers/testcontainers-dotnet/issues/1504"],
},
("PULSAR","AUTH_FAIL"): {
    "specific": "JWT/Token 认证失败返回 HTTP 401 / `PulsarClientException$AuthenticationException`",
    "src": "Pulsar authentication failure — [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/) / [GitHub #10733](https://github.com/apache/pulsar/issues/10733)",
    "urls": ["https://pulsar.apache.org/docs/security/01security/","https://github.com/apache/pulsar/issues/10733"],
},
("PULSAR","QUOTA_EXCEED"): {
    "specific": "命名空间资源配额或 producer 队列满触发 `ProducerBlockedQuotaExceededError` / `broker busy`",
    "src": "Pulsar quota/backpressure — [Pulsar Python Producer API](https://pulsar.apache.org/api/python/3.0.x/pulsar.Producer.html) / [GitHub #26343](https://github.com/apache/pulsar/issues/26343)",
    "urls": ["https://pulsar.apache.org/api/python/3.0.x/pulsar.Producer.html","https://github.com/apache/pulsar/issues/26343"],
},
("PULSAR","TIMEOUT"): {
    "specific": "producer `sendTimeout` 默认 30000ms 内未收到 ack 时抛出 `PulsarClientException.TimeoutException`",
    "src": "Pulsar sendTimeout default 30s — [Pulsar Client Java API](https://pulsar.apache.org/api/client/4.0.x/index-all.html) / [pulsar-client-go #1312](https://github.com/apache/pulsar-client-go/issues/1312)",
    "urls": ["https://pulsar.apache.org/api/client/4.0.x/index-all.html","https://github.com/apache/pulsar-client-go/issues/1312"],
},
("PULSAR","MALFORMED"): {
    "specific": "schema 不兼容或消息格式非法触发 `IncompatibleSchemaException` / `InvalidMessageException`",
    "src": "Pulsar schema/message validation — [Pulsar IncompatibleSchemaException JavaDoc](https://pulsar.apache.org/api/client/2.11.x/org/apache/pulsar/client/api/PulsarClientException.IncompatibleSchemaException.html) / [GitHub #23916](https://github.com/apache/pulsar/issues/23916)",
    "urls": ["https://pulsar.apache.org/api/client/2.11.x/org/apache/pulsar/client/api/PulsarClientException.IncompatibleSchemaException.html","https://github.com/apache/pulsar/issues/23916"],
},
("PULSAR","PERM_DENIED"): {
    "specific": "tenant/namespace 权限不足返回 `AuthorizationException` / HTTP 403 Forbidden",
    "src": "Pulsar authorization — [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/) / [GitHub #10733](https://github.com/apache/pulsar/issues/10733)",
    "urls": ["https://pulsar.apache.org/docs/security/01security/","https://github.com/apache/pulsar/issues/10733"],
},
("PULSAR","CONN_RESET"): {
    "specific": "broker 重启或网络闪断导致 Netty `IOException` / `Connection reset by peer`，客户端自动重连",
    "src": "Pulsar connection reset — [GitHub #10231](https://github.com/apache/pulsar/issues/10231) / [pulsar-client-go #1312](https://github.com/apache/pulsar-client-go/issues/1312)",
    "urls": ["https://github.com/apache/pulsar/issues/10231","https://github.com/apache/pulsar-client-go/issues/1312"],
},
("PULSAR","BCKPRESSURE_OVF"): {
    "specific": "producer pending queue 满且 `blockIfQueueFull=false` 时抛出 `ProducerQueueIsFullError`",
    "src": "Pulsar producer queue full — [Pulsar Client Java API](https://pulsar.apache.org/api/client/4.0.x/index-all.html) / [jianshu producer async](https://www.jianshu.com/p/78112dcb3436)",
    "urls": ["https://pulsar.apache.org/api/client/4.0.x/index-all.html","https://www.jianshu.com/p/78112dcb3436"],
},
("PULSAR","VER_MISMATCH"): {
    "specific": "客户端与服务端版本或协议不兼容导致 handshake / `IncompatibleSchemaException` 失败",
    "src": "Pulsar client/server compatibility — [Alibaba Cloud](https://developer.aliyun.com/ask/575669) / [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/)",
    "urls": ["https://developer.aliyun.com/ask/575669","https://pulsar.apache.org/docs/security/01security/"],
},
("PULSAR","RES_EXH"): {
    "specific": "Bookie/JVM 内存或磁盘耗尽导致写入失败、broker OOM 或 FD 耗尽",
    "src": "Pulsar resource exhaustion — [Apache Pulsar Security](https://pulsar.apache.org/docs/security/01security/) / [Apache Pulsar Message Deduplication](https://pulsar.apache.org/docs/2.4.0/cookbooks-deduplication/)",
    "urls": ["https://pulsar.apache.org/docs/security/01security/","https://pulsar.apache.org/docs/2.4.0/cookbooks-deduplication/"],
},

("ROCKETMQ","UNKWON_TOPIC"): {
    "specific": "向未创建 topic 发送返回 `MQBrokerException: CODE: 17 DESC: topic[...] not exist, apply first please!`",
    "src": "RocketMQ topic not exist code 17 — [GitHub rocketmq-mqtt #165](https://github.com/apache/rocketmq-mqtt/issues/165) / [Stack Overflow](https://stackoverflow.com/questions/43154365/rocketmqmqbrokerexception-code-2-desc-timeout-clean-queue)",
    "urls": ["https://github.com/apache/rocketmq-mqtt/issues/165","https://stackoverflow.com/questions/43154365/rocketmqmqbrokerexception-code-2-desc-timeout-clean-queue"],
},
("ROCKETMQ","AUTH_FAIL"): {
    "specific": "ACL/Token 认证失败返回 `MQBrokerException: CODE: 1 DESC: AclException ... Token authentication failed`",
    "src": "RocketMQ ACL auth failure — [Apache RocketMQ Access Control](https://rocketmq.apache.org/docs/bestPractice/06access/) / [Tencent Cloud](https://www.tencentcloud.com/zh/document/product/1113/54437)",
    "urls": ["https://rocketmq.apache.org/docs/bestPractice/06access/","https://www.tencentcloud.com/zh/document/product/1113/54437"],
},
("ROCKETMQ","QUOTA_EXCEED"): {
    "specific": "broker 队列繁忙/流控返回 `CODE: 2 DESC: [TIMEOUT_CLEAN_QUEUE]broker busy, start flow control`",
    "src": "RocketMQ broker busy code 2 — [Stack Overflow](https://stackoverflow.com/questions/43154365/rocketmqmqbrokerexception-code-2-desc-timeout-clean-queue) / [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/)",
    "urls": ["https://stackoverflow.com/questions/43154365/rocketmqmqbrokerexception-code-2-desc-timeout-clean-queue","https://rocketmq.apache.org/docs/4.x/faq/"],
},
("ROCKETMQ","TIMEOUT"): {
    "specific": "同步发送在 `sendMsgTimeout` 默认 3000ms 未收到响应时抛出 `RemotingTimeoutException`",
    "src": "RocketMQ sendMsgTimeout default 3000ms — [RocketMQ Client Config](https://rocketmq.apache.org/docs/4.x/parameterConfiguration/01local/) / [jaskey blog](https://jaskey.github.io/blog/2017/06/13/rocketmq-client-config/)",
    "urls": ["https://rocketmq.apache.org/docs/4.x/parameterConfiguration/01local/","https://jaskey.github.io/blog/2017/06/13/rocketmq-client-config/"],
},
("ROCKETMQ","MALFORMED"): {
    "specific": "消息体/RemotingCommand 解码失败返回 `CODE: 1` / `MQClientException` / `RemotingCommandException`",
    "src": "RocketMQ malformed/command decode — [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/) / [GitHub #3750](https://github.com/apache/rocketmq/issues/3750)",
    "urls": ["https://rocketmq.apache.org/docs/4.x/faq/","https://github.com/apache/rocketmq/issues/3750"],
},
("ROCKETMQ","PERM_DENIED"): {
    "specific": "ACL 权限不足返回 `NO_PERMISSION` / `AclException: [PRODUCE/SUBSCRIBE] ... no permission`",
    "src": "RocketMQ ACL permission denied — [RocketMQ Access Control 4.x](https://rocketmq.apache.org/docs/4.x/bestPractice/04access/) / [Tencent Cloud](https://www.tencentcloud.com/zh/document/product/1113/54437)",
    "urls": ["https://rocketmq.apache.org/docs/4.x/bestPractice/04access/","https://www.tencentcloud.com/zh/document/product/1113/54437"],
},
("ROCKETMQ","CONN_RESET"): {
    "specific": "namesrv/broker 不可达或 TCP 重置时抛出 `RemotingConnectException` / `Connection reset by peer`",
    "src": "RocketMQ connection reset — [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/) / [GitHub #3750](https://github.com/apache/rocketmq/issues/3750)",
    "urls": ["https://rocketmq.apache.org/docs/4.x/faq/","https://github.com/apache/rocketmq/issues/3750"],
},
("ROCKETMQ","BCKPRESSURE_OVF"): {
    "specific": "异步发送过快触发 `RemotingTooMuchRequestException` / `broker busy`，客户端进入流控",
    "src": "RocketMQ too much request flow control — [Stack Overflow](https://stackoverflow.com/questions/46767541/org-apache-rocketmq-remoting-exception-remotingtoomuchrequestexception-invokeas) / [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/)",
    "urls": ["https://stackoverflow.com/questions/46767541/org-apache-rocketmq-remoting-exception-remotingtoomuchrequestexception-invokeas","https://rocketmq.apache.org/docs/4.x/faq/"],
},
("ROCKETMQ","VER_MISMATCH"): {
    "specific": "客户端与服务端 remoting 协议或大版本不兼容导致握手失败或空指针异常",
    "src": "RocketMQ version compatibility — [Alibaba Cloud](https://developer.aliyun.com/ask/575669) / [RocketMQ FAQ](https://rocketmq.apache.org/docs/faq/)",
    "urls": ["https://developer.aliyun.com/ask/575669","https://rocketmq.apache.org/docs/faq/"],
},
("ROCKETMQ","RES_EXH"): {
    "specific": "broker JVM OOM、commitlog 磁盘满或 FD 耗尽导致写入拒绝或服务不可用",
    "src": "RocketMQ resource exhaustion — [RocketMQ FAQ](https://rocketmq.apache.org/docs/4.x/faq/) / [GitHub #3750](https://github.com/apache/rocketmq/issues/3750)",
    "urls": ["https://rocketmq.apache.org/docs/4.x/faq/","https://github.com/apache/rocketmq/issues/3750"],
},

("REDIS","UNKWON_TOPIC"): {
    "specific": "对不存在的 stream 执行 `XGROUP CREATE`（无 MKSTREAM）返回 `ERR The XGROUP subcommand requires the key to exist.`",
    "src": "Redis XGROUP CREATE key-must-exist — [Redis Docs](https://redis.io/docs/latest/commands/xgroup-create/) / [OneUptime](https://oneuptime.com/blog/post/2026-03-31-redis-how-to-use-xgroup-create-in-redis-to-create-consumer-groups/view)",
    "urls": ["https://redis.io/docs/latest/commands/xgroup-create/","https://oneuptime.com/blog/post/2026-03-31-redis-how-to-use-xgroup-create-in-redis-to-create-consumer-groups/view"],
},
("REDIS","AUTH_FAIL"): {
    "specific": "ACL/密码错误返回 `WRONGPASS invalid username-password pair` / `NOAUTH Authentication required`",
    "src": "Redis WRONGPASS — [Alibaba Cloud](https://www.alibabacloud.com/help/en/redis/support/what-do-i-do-if-the-wrongpass-invalid-username-password-pair-error-message-is-returned-when-i-attempt-to-connect-to-an-apsaradb-for-redis-instance) / [Redis AUTH](https://redis.io/docs/latest/commands/auth/)",
    "urls": ["https://www.alibabacloud.com/help/en/redis/support/what-do-i-do-if-the-wrongpass-invalid-username-password-pair-error-message-is-returned-when-i-attempt-to-connect-to-an-apsaradb-for-redis-instance","https://redis.io/docs/latest/commands/auth/"],
},
("REDIS","QUOTA_EXCEED"): {
    "specific": "达到 `maxmemory` 上限且策略为 `noeviction` 时写命令返回 `OOM command not allowed when used memory > 'maxmemory'.`",
    "src": "Redis OOM quota — [Mattias Geniar](https://ma.ttias.be/redis-oom-command-not-allowed-used-memory-maxmemory/) / [Redis CONFIG SET](https://redis.io/docs/latest/commands/config-set/)",
    "urls": ["https://ma.ttias.be/redis-oom-command-not-allowed-used-memory-maxmemory/","https://redis.io/docs/latest/commands/config-set/"],
},
("REDIS","TIMEOUT"): {
    "specific": "客户端 socket 超时或阻塞命令（如 `BLPOP`）等待超时；空闲连接被 `timeout` 配置关闭",
    "src": "Redis client timeout — [Redis Clients](https://redis.io/docs/latest/develop/reference/clients/) / [BLPOP](https://redis.io/docs/latest/commands/blpop/)",
    "urls": ["https://redis.io/docs/latest/develop/reference/clients/","https://redis.io/docs/latest/commands/blpop/"],
},
("REDIS","MALFORMED"): {
    "specific": "非法 RESP 帧/非法 UTF-8/命令参数错误返回 `ERR Protocol error` / `ERR wrong number of arguments`",
    "src": "Redis RESP protocol errors — [Redis Protocol](https://redis.io/docs/latest/develop/reference/protocol-spec/) / [Redis Commands](https://redis.io/docs/latest/commands/)",
    "urls": ["https://redis.io/docs/latest/develop/reference/protocol-spec/","https://redis.io/docs/latest/commands/"],
},
("REDIS","PERM_DENIED"): {
    "specific": "ACL 禁止某命令/键时返回 `NOPERM this user has no permissions to run the ...`",
    "src": "Redis ACL NOPERM — [Redis ACL](https://redis.io/docs/latest/manual/acl/) / [Redis AUTH](https://redis.io/docs/latest/commands/auth/)",
    "urls": ["https://redis.io/docs/latest/manual/acl/","https://redis.io/docs/latest/commands/auth/"],
},
("REDIS","CONN_RESET"): {
    "specific": "空闲连接被 server 关闭或网络重置时客户端收到 `Connection reset by peer` / `ErrConnectionClosed`",
    "src": "Redis connection reset — [Redis Clients](https://redis.io/docs/latest/develop/reference/clients/) / [Redis XGROUP CREATE](https://redis.io/docs/latest/commands/xgroup-create/)",
    "urls": ["https://redis.io/docs/latest/develop/reference/clients/","https://redis.io/docs/latest/commands/xgroup-create/"],
},
("REDIS","BCKPRESSURE_OVF"): {
    "specific": "Pub/Sub 输出缓冲区超过 `client-output-buffer-limit` 时 server 主动 `CLIENT KILL` 该客户端",
    "src": "Redis client output buffer limit — [Redis Clients](https://redis.io/docs/latest/develop/reference/clients/) / [CLIENT KILL](https://redis.io/docs/latest/commands/client-kill/)",
    "urls": ["https://redis.io/docs/latest/develop/reference/clients/","https://redis.io/docs/latest/commands/client-kill/"],
},
("REDIS","VER_MISMATCH"): {
    "specific": "RESP3 协商失败（如对 RESP2 server 发送 `HELLO 3`）返回 `-ERR unknown command` 或协议错误",
    "src": "Redis RESP version / HELLO — [Redis HELLO](https://redis.io/docs/latest/commands/hello/) / [Redis Protocol](https://redis.io/docs/latest/develop/reference/protocol-spec/)",
    "urls": ["https://redis.io/docs/latest/commands/hello/","https://redis.io/docs/latest/develop/reference/protocol-spec/"],
},
("REDIS","RES_EXH"): {
    "specific": "内存耗尽 `OOM command not allowed` 或连接数达到 `maxclients` 返回 `ERR max number of clients reached`",
    "src": "Redis resource exhaustion — [Redis Clients](https://https://redis.io/docs/latest/develop/reference/clients/) / [OneUptime maxclients](https://oneuptime.com/blog/post/2026-01-25-redis-max-clients-reached-fix/view)",
    "urls": ["https://redis.io/docs/latest/develop/reference/clients/","https://oneuptime.com/blog/post/2026-01-25-redis-max-clients-reached-fix/view"],
},

("MQTT","UNKWON_TOPIC"): {
    "specific": "向非法/不存在的主题发布或订阅时 v5 返回 `0x90 Topic Name invalid`（PUBACK/SUBACK/DISCONNECT）",
    "src": "MQTT v5 `Topic Name invalid` 0x90 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","AUTH_FAIL"): {
    "specific": "CONNECT 认证失败返回 `0x86 Bad User Name or Password` 或 `0x87 Not authorized`",
    "src": "MQTT v5 auth reason codes 0x86/0x87 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","QUOTA_EXCEED"): {
    "specific": "超出接收配额或最大包大小时 v5 返回 `0x97 Quota exceeded` / `0x95 Packet too large`",
    "src": "MQTT v5 quota 0x97 — [Tencent Cloud](https://www.tencentcloud.com/document/product/1294/76755) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://www.tencentcloud.com/document/product/1294/76755","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","TIMEOUT"): {
    "specific": "Keep Alive 超时 server 发送 `0x8D Keep Alive timeout` DISCONNECT 并关闭连接",
    "src": "MQTT v5 keep alive timeout 0x8D — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","MALFORMED"): {
    "specific": "畸形包触发 server 发送 `0x81 Malformed Packet` 或 `0x82 Protocol Error` DISCONNECT",
    "src": "MQTT v5 malformed 0x81/0x82 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","PERM_DENIED"): {
    "specific": "ACL 拒绝发布/订阅时返回 `0x87 Not authorized`（CONNACK/PUBACK/SUBACK/DISCONNECT）",
    "src": "MQTT v5 not authorized 0x87 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","CONN_RESET"): {
    "specific": "broker 强制断开或网络 RST 时客户端收到 `Connection reset by peer`，cleanSession=false 时重连恢复会话",
    "src": "MQTT connection reset / session recovery — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","BCKPRESSURE_OVF"): {
    "specific": "超过 `Receive Maximum` 或 `Maximum Packet Size` 时 broker 暂停发送或返回 `0x93 Receive Maximum exceeded` / `0x95 Packet too large`",
    "src": "MQTT v5 flow control / packet size — [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html) / [Merobix](https://www.merobix.com/blog/what-is-mqtt-maximum-packet-size)",
    "urls": ["https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html","https://www.merobix.com/blog/what-is-mqtt-maximum-packet-size"],
},
("MQTT","VER_MISMATCH"): {
    "specific": "客户端请求不支持的协议版本时 server 返回 `0x84 Unsupported Protocol Version`",
    "src": "MQTT v5 unsupported protocol version 0x84 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
("MQTT","RES_EXH"): {
    "specific": "broker 资源耗尽时返回 `0x88 Server unavailable` / `0x89 Server busy` 或强制断开连接",
    "src": "MQTT v5 server unavailable/busy 0x88/0x89 — [OASIS MQTT v5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html) / [EMQX Error Codes](https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html)",
    "urls": ["https://docs.oasis-open.org/mqtt/mqtt/v5.0/cos01/mqtt-v5.0-cos01.html","https://docs.emqx.com/en/cloud/latest/connect_to_deployments/mqtt_client_error_codes.html"],
},
}

# Given / When 默认模板（按错误类）
ERR_GIVEN = {
    "UNKWON_TOPIC": "目标 topic/queue/stream 未创建或已被删除",
    "AUTH_FAIL": "使用错误凭证或缺失凭证连接 broker",
    "QUOTA_EXCEED": "将某用户/流/租户压测至配置配额上限",
    "TIMEOUT": "网络延迟注入或 broker 处理延迟超过客户端超时阈值",
    "MALFORMED": "构造坏 JSON、超 frame、非法 UTF-8 或 CRC 错误的消息/帧",
    "PERM_DENIED": "使用低权限 principal 执行越权生产/消费/管理操作",
    "CONN_RESET": "在连接活动期间注入 TCP RST 或半开连接/强制关闭 broker 端口",
    "BCKPRESSURE_OVF": "以高于消费速度的生产速率灌入，直至缓冲/队列/ack pending 满",
    "VER_MISMATCH": "使用旧版客户端或错误协议版本连接当前 broker",
    "RES_EXH": "将 broker 节点的 FD/内存/磁盘压至上限",
}
ERR_WHEN = {
    "UNKWON_TOPIC": "客户端向该不存在的资源执行 publish/consume/declare/create group",
    "AUTH_FAIL": "客户端发起 CONNECT/SASL 握手或带 Token 的请求",
    "QUOTA_EXCEED": "持续发送直到触发配额/限速/存储上限",
    "TIMEOUT": "等待响应/ack/心跳超时",
    "MALFORMED": "发送/消费该畸形消息或帧",
    "PERM_DENIED": "执行被 ACL 禁止的操作",
    "CONN_RESET": "观察客户端在连接异常关闭后的行为",
    "BCKPRESSURE_OVF": "继续生产并观察 broker/客户端背压行为",
    "VER_MISMATCH": "进行协议握手或 ApiVersions 协商",
    "RES_EXH": "继续请求并观察 broker 降级行为",
}

def existing_ids():
    ids = set()
    if not os.path.exists(REGISTRY):
        return ids
    with open(REGISTRY, encoding="utf-8") as f:
        for line in f:
            if not line.strip() or line.startswith("#") or line.startswith("id"):
                continue
            parts = line.rstrip("\r\n").split("\t")
            if parts and parts[0].startswith("TC-ERR-"):
                ids.add(parts[0])
    return ids

existing = existing_ids()
made, reg_rows = 0, []
sources_per_sys = {s: set() for s in SYSTEMS}

for sys_ in SYSTEMS:
    for err in ERRORS:
        cid = f"TC-ERR-{sys_}-{err}-01"
        meta = SPECIFIC.get((sys_, err))
        if not meta:
            continue
        d = os.path.join(BASE, "cases", sys_.lower(), err.lower())
        os.makedirs(d, exist_ok=True)
        thens = [meta["specific"]] + DEFAULT_THENS[err]
        body = f"""# {cid}：{sys_} {ERR_NAME[err]} 边界测试

> **维度**：系统={sys_} | 错误类={err} | 断言面：CLI/admin/metrics+客户端异常
> **行为依据**：{meta['src']}
> **环境**：E2；**状态**：pending

## Given

- {ERR_GIVEN[err]}

## When

- {ERR_WHEN[err]}

## Then

"""
        body += "".join(f"- {t}\n" for t in thens)
        body += f"""
## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/{sys_.lower()}/{err.lower()}/{cid}.sh   # 计划打印（挂账）
```

## 关联

- 01-63 错误码矩阵 / 01-64 MQTT 错误语义 / 01-72 消息大小矩阵 / 03-68 运行行为档案
"""
        with open(os.path.join(d, cid + ".md"), "w", encoding="utf-8", newline="\n") as f:
            f.write(body)
        for u in meta.get("urls", []):
            sources_per_sys[sys_].add(u)
        if cid not in existing:
            reg_rows.append(f"{cid}\tERR\t-\tE2\t08-运维行为测试\tpending")
            made += 1

if reg_rows:
    with open(REGISTRY, "a", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(reg_rows) + "\n")

print(f"err_cases={len(SYSTEMS)*len(ERRORS)}")
print(f"registry_appended={made}")
for sys_ in SYSTEMS:
    print(f"sources_{sys_.lower()}={len(sources_per_sys[sys_])}")
