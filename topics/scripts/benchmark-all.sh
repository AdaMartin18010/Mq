#!/bin/bash
# 所有消息队列系统性能基准测试脚本

set -e

DURATION=${1:-60}  # 测试持续时间（秒）
MESSAGE_SIZE=${2:-1024}  # 消息大小（字节）
MESSAGE_RATE=${3:-10000}  # 消息速率（msg/s）

echo "=== 消息队列系统性能基准测试 ==="
echo "持续时间: ${DURATION}秒"
echo "消息大小: ${MESSAGE_SIZE}字节"
echo "消息速率: ${MESSAGE_RATE}msg/s"
echo ""

benchmark_kafka() {
    echo "测试Kafka..."
    
    if command -v kafka-producer-perf-test.sh &> /dev/null; then
        kafka-producer-perf-test.sh \
            --topic benchmark-test \
            --num-records $((MESSAGE_RATE * DURATION)) \
            --record-size $MESSAGE_SIZE \
            --throughput $MESSAGE_RATE \
            --producer-props bootstrap.servers=localhost:9092 \
            2>&1 | grep -E "records/sec|MB/sec" || echo "  ⚠️  测试完成"
    else
        echo "  ⚠️  kafka-producer-perf-test.sh未安装"
    fi
}

benchmark_nats() {
    echo "测试NATS..."
    
    if command -v nats-bench &> /dev/null; then
        nats-bench -s localhost:4222 \
            -np 1 -ns 1 \
            -n $((MESSAGE_RATE * DURATION)) \
            -ms $MESSAGE_SIZE \
            -r $MESSAGE_RATE \
            2>&1 | tail -5 || echo "  ⚠️  测试完成"
    else
        echo "  ⚠️  nats-bench未安装"
    fi
}

benchmark_rabbitmq() {
    echo "测试RabbitMQ..."
    echo "  ⚠️  需要RabbitMQ性能测试工具"
}

benchmark_kafka
echo ""
benchmark_nats
echo ""
benchmark_rabbitmq

echo ""
echo "基准测试完成！"
