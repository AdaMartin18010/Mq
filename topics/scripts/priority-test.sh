#!/bin/bash
# 消息优先级测试脚本

set -e

MQ_TYPE=${1:-"rabbitmq"}

echo "=== 消息优先级测试 ==="
echo ""

test_kafka_priority() {
    echo "Kafka优先级测试:"
    echo "  Kafka优先级实现:"
    echo "    - 使用不同Topic实现优先级"
    echo "    - 高优先级: orders-high"
    echo "    - 普通优先级: orders-normal"
    echo "    - Consumer优先消费高优先级Topic"
}

test_nats_priority() {
    echo "NATS优先级测试:"
    echo "  NATS优先级实现:"
    echo "    - 使用不同Subject实现优先级"
    echo "    - 高优先级: orders.high"
    echo "    - 普通优先级: orders.normal"
    echo "    - 消费者订阅多个Subject"
}

test_rabbitmq_priority() {
    echo "RabbitMQ优先级测试:"
    echo "  RabbitMQ优先级实现:"
    echo "    - 使用优先级队列"
    echo "    - 设置x-max-priority参数"
    echo "    - 消息设置priority属性"
    echo ""
    echo "  示例:"
    echo "    channel.queue_declare("
    echo "        queue='orders',"
    echo "        arguments={'x-max-priority': 10}"
    echo "    )"
    echo "    channel.basic_publish("
    echo "        properties=pika.BasicProperties(priority=10)"
    echo "    )"
}

case $MQ_TYPE in
    kafka)
        test_kafka_priority
        ;;
    nats)
        test_nats_priority
        ;;
    rabbitmq)
        test_rabbitmq_priority
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息优先级测试完成！"
