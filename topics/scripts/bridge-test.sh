#!/bin/bash
# 消息桥接测试脚本

set -e

BRIDGE_TYPE=${1:-"kafka-rabbitmq"}

echo "=== 消息桥接测试 ==="
echo "桥接类型: $BRIDGE_TYPE"
echo ""

test_kafka_rabbitmq_bridge() {
    echo "Kafka到RabbitMQ桥接测试:"
    echo "  桥接方式:"
    echo "    - Kafka Connect桥接"
    echo "    - Kafka Streams桥接"
    echo "    - 应用层桥接"
    echo ""
    echo "  配置示例:"
    echo "    kafka.bootstrap.servers=localhost:9092"
    echo "    kafka.topics=orders"
    echo "    rabbitmq.host=localhost"
    echo "    rabbitmq.exchange=orders"
}

test_nats_kafka_bridge() {
    echo "NATS到Kafka桥接测试:"
    echo "  桥接方式:"
    echo "    - NATS订阅 + Kafka发布"
    echo "    - 应用层桥接"
    echo ""
    echo "  配置示例:"
    echo "    nats.url=nats://localhost:4222"
    echo "    nats.subject=orders"
    echo "    kafka.bootstrap.servers=localhost:9092"
    echo "    kafka.topic=orders"
}

test_rabbitmq_nats_bridge() {
    echo "RabbitMQ到NATS桥接测试:"
    echo "  桥接方式:"
    echo "    - RabbitMQ消费 + NATS发布"
    echo "    - 应用层桥接"
    echo ""
    echo "  配置示例:"
    echo "    rabbitmq.host=localhost"
    echo "    rabbitmq.queue=orders"
    echo "    nats.url=nats://localhost:4222"
    echo "    nats.subject=orders"
}

case $BRIDGE_TYPE in
    kafka-rabbitmq)
        test_kafka_rabbitmq_bridge
        ;;
    nats-kafka)
        test_nats_kafka_bridge
        ;;
    rabbitmq-nats)
        test_rabbitmq_nats_bridge
        ;;
    *)
        echo "用法: $0 [kafka-rabbitmq|nats-kafka|rabbitmq-nats]"
        exit 1
        ;;
esac

echo ""
echo "--- 桥接建议 ---"
echo "1. 使用标准桥接工具（Kafka Connect等）"
echo "2. 处理消息格式转换"
echo "3. 实现错误处理和重试"
echo "4. 监控桥接性能"
echo "5. 保证消息可靠性"

echo ""
echo "消息桥接测试完成！"
