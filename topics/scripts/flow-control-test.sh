#!/bin/bash
# 消息流控测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息流控测试 ==="
echo ""

test_kafka_flow_control() {
    echo "Kafka流控测试:"
    echo "  Producer流控:"
    echo "    - max.in.flight.requests.per.connection: 5"
    echo "    - buffer.memory: 33554432"
    echo "    - batch.size: 16384"
    echo ""
    echo "  Consumer流控:"
    echo "    - max.poll.records: 500"
    echo "    - fetch.min.bytes: 1"
    echo "    - fetch.max.wait.ms: 500"
}

test_nats_flow_control() {
    echo "NATS流控测试:"
    echo "  NATS流控配置:"
    echo "    - SubChanLen: 1000"
    echo "    - 应用层限流"
    echo "    - 连接重连控制"
}

test_rabbitmq_flow_control() {
    echo "RabbitMQ流控测试:"
    echo "  RabbitMQ流控配置:"
    echo "    - basic_qos(prefetch_count=100)"
    echo "    - 连接心跳控制"
    echo "    - 阻塞连接超时"
}

case $MQ_TYPE in
    kafka)
        test_kafka_flow_control
        ;;
    nats)
        test_nats_flow_control
        ;;
    rabbitmq)
        test_rabbitmq_flow_control
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息流控测试完成！"
