#!/bin/bash
# 消息队列性能测试脚本

set -e

echo "=== 消息队列性能测试 ==="

# 测试类型
TEST_TYPE=${1:-"kafka"}

case $TEST_TYPE in
    kafka)
        echo "测试Kafka性能..."
        # 使用kafka-producer-perf-test.sh
        if [ -f "kafka_*/bin/kafka-producer-perf-test.sh" ]; then
            kafka_*/bin/kafka-producer-perf-test.sh \
                --topic test-topic \
                --num-records 1000000 \
                --record-size 1024 \
                --throughput 100000 \
                --producer-props bootstrap.servers=localhost:9092
        else
            echo "错误: 未找到Kafka性能测试工具"
        fi
        ;;
    nats)
        echo "测试NATS性能..."
        # 使用nats-bench
        if command -v nats-bench &> /dev/null; then
            nats-bench -s localhost:4222 -np 1 -ns 1 -n 1000000 -ms 1024
        else
            echo "安装nats-bench: go install github.com/nats-io/nats.go/examples/nats-bench@latest"
        fi
        ;;
    rabbitmq)
        echo "测试RabbitMQ性能..."
        # 使用perf-test工具
        if [ -f "rabbitmq-server-*/sbin/rabbitmq-server" ]; then
            echo "使用RabbitMQ PerfTest工具"
        else
            echo "安装RabbitMQ PerfTest: https://github.com/rabbitmq/rabbitmq-perf-test"
        fi
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo "性能测试完成！"
