#!/bin/bash
# 消息队列基准测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
DURATION=${2:-60}  # 测试时长（秒）
RATE=${3:-10000}   # 消息速率（msg/s）

echo "=== 消息队列基准测试 ==="
echo "系统: $MQ_TYPE"
echo "时长: ${DURATION}秒"
echo "速率: ${RATE} msg/s"
echo ""

benchmark_kafka() {
    echo "Kafka基准测试..."
    
    if ! command -v kafka-producer-perf-test.sh &> /dev/null; then
        echo "❌ 未找到kafka-producer-perf-test.sh"
        return 1
    fi
    
    # 创建测试Topic
    kafka-topics.sh --create --topic benchmark-test \
        --bootstrap-server localhost:9092 \
        --partitions 3 --replication-factor 1 2>/dev/null || true
    
    # 运行性能测试
    kafka-producer-perf-test.sh \
        --topic benchmark-test \
        --num-records $((RATE * DURATION)) \
        --record-size 1024 \
        --throughput $RATE \
        --producer-props bootstrap.servers=localhost:9092 \
        acks=1 batch.size=16384 linger.ms=10
}

benchmark_nats() {
    echo "NATS基准测试..."
    
    if ! command -v nats-bench &> /dev/null; then
        echo "安装nats-bench: go install github.com/nats-io/nats.go/examples/nats-bench@latest"
        return 1
    fi
    
    nats-bench -s localhost:4222 \
        -np 1 -ns 1 \
        -n $((RATE * DURATION)) \
        -ms 1024 \
        -r $RATE
}

benchmark_rabbitmq() {
    echo "RabbitMQ基准测试..."
    
    if ! command -v rabbitmq-perf-test &> /dev/null; then
        echo "安装RabbitMQ PerfTest: https://github.com/rabbitmq/rabbitmq-perf-test"
        return 1
    fi
    
    rabbitmq-perf-test -x 1 -y 1 \
        -u "amqp://guest:guest@localhost:5672" \
        -s 1024 \
        -r $RATE \
        -z $DURATION
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
        echo "用法: $0 [kafka|nats|rabbitmq] [duration] [rate]"
        exit 1
        ;;
esac

echo ""
echo "基准测试完成！"
