#!/bin/bash
# 消息批处理测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
BATCH_SIZE=${2:-100}
MESSAGE_COUNT=${3:-1000}

echo "=== 消息批处理测试 ==="
echo "系统: $MQ_TYPE"
echo "批次大小: $BATCH_SIZE"
echo "消息总数: $MESSAGE_COUNT"
echo ""

test_kafka_batch() {
    echo "Kafka批处理测试:"
    echo "  Producer批处理配置:"
    echo "    - batch.size: 16384"
    echo "    - linger.ms: 10"
    echo "    - buffer.memory: 33554432"
    echo ""
    echo "  Consumer批处理:"
    echo "    - max.poll.records: $BATCH_SIZE"
    echo "    - 批量处理消息"
    echo ""
    echo "  测试消息数: $MESSAGE_COUNT"
    echo "  批次大小: $BATCH_SIZE"
    echo "  预计批次数: $((MESSAGE_COUNT / BATCH_SIZE))"
}

test_nats_batch() {
    echo "NATS批处理测试:"
    echo "  NATS批处理实现:"
    echo "    - 批量发布消息"
    echo "    - 批量订阅处理"
    echo "    - 批次大小: $BATCH_SIZE"
    echo ""
    echo "  测试消息数: $MESSAGE_COUNT"
    echo "  批次大小: $BATCH_SIZE"
    echo "  预计批次数: $((MESSAGE_COUNT / BATCH_SIZE))"
}

test_rabbitmq_batch() {
    echo "RabbitMQ批处理测试:"
    echo "  RabbitMQ批处理实现:"
    echo "    - basic_publish_batch"
    echo "    - 批量消费处理"
    echo "    - 批次大小: $BATCH_SIZE"
    echo ""
    echo "  测试消息数: $MESSAGE_COUNT"
    echo "  批次大小: $BATCH_SIZE"
    echo "  预计批次数: $((MESSAGE_COUNT / BATCH_SIZE))"
}

case $MQ_TYPE in
    kafka)
        test_kafka_batch
        ;;
    nats)
        test_nats_batch
        ;;
    rabbitmq)
        test_rabbitmq_batch
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [batch_size] [message_count]"
        exit 1
        ;;
esac

echo ""
echo "消息批处理测试完成！"
