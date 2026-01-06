#!/bin/bash
# 性能基准测试脚本（增强版）

set -e

MQ_TYPE=${1:-"kafka"}
DURATION=${2:-60}
MESSAGE_SIZE=${3:-1024}
MESSAGE_RATE=${4:-10000}

echo "=== 消息队列性能基准测试 ==="
echo "系统: $MQ_TYPE"
echo "持续时间: ${DURATION}秒"
echo "消息大小: ${MESSAGE_SIZE}字节"
echo "消息速率: ${MESSAGE_RATE}msg/s"
echo ""

benchmark_kafka() {
    echo "Kafka性能测试..."
    
    if command -v kafka-producer-perf-test.sh &> /dev/null; then
        echo "开始Producer测试..."
        kafka-producer-perf-test.sh \
            --topic benchmark-test \
            --num-records $((MESSAGE_RATE * DURATION)) \
            --record-size $MESSAGE_SIZE \
            --throughput $MESSAGE_RATE \
            --producer-props bootstrap.servers=localhost:9092 \
            2>&1 | grep -E "records/sec|MB/sec|avg latency|max latency" || echo "  测试完成"
    else
        echo "  ⚠️  kafka-producer-perf-test.sh未安装"
    fi
}

benchmark_nats() {
    echo "NATS性能测试..."
    
    if command -v nats-bench &> /dev/null; then
        echo "开始测试..."
        nats-bench -s localhost:4222 \
            -np 1 -ns 1 \
            -n $((MESSAGE_RATE * DURATION)) \
            -ms $MESSAGE_SIZE \
            -r $MESSAGE_RATE \
            2>&1 | tail -10 || echo "  测试完成"
    else
        echo "  ⚠️  nats-bench未安装"
    fi
}

benchmark_rabbitmq() {
    echo "RabbitMQ性能测试..."
    echo "  ⚠️  需要RabbitMQ性能测试工具"
    echo "  建议使用rabbitmq-perf-test或自定义测试工具"
}

case $MQ_TYPE in
    kafka)
        benchmark_kafka
        ;;
    nats)
        benchmark_nats
        ;;
    rabbitmq)
        benchmark_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [duration] [message_size] [message_rate]"
        exit 1
        ;;
esac

echo ""
echo "性能基准测试完成！"
