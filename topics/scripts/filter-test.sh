#!/bin/bash
# 消息过滤测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息过滤测试 ==="
echo ""

test_kafka_filter() {
    echo "Kafka消息过滤测试:"
    echo "  Kafka过滤建议:"
    echo "    - 使用Consumer端过滤"
    echo "    - 使用Kafka Streams"
    echo "    - 合理使用分区"
    echo ""
    echo "  示例:"
    echo "    consumer.subscribe(Collections.singletonList(\"orders\"));"
    echo "    // 应用层过滤"
    echo "    if (shouldProcess(record.value())) {"
    echo "        process(record);"
    echo "    }"
}

test_nats_filter() {
    echo "NATS消息过滤测试:"
    echo "  NATS过滤特性:"
    echo "    - 通配符过滤: orders.*.created"
    echo "    - 队列组过滤: QueueSubscribe"
    echo "    - 应用层过滤: 消息内容过滤"
    echo ""
    echo "  示例:"
    echo "    nc.Subscribe(\"orders.*.created\", func(msg *nats.Msg) {"
    echo "        process(msg)"
    echo "    })"
}

test_rabbitmq_filter() {
    echo "RabbitMQ消息过滤测试:"
    echo "  RabbitMQ过滤方式:"
    echo "    - Topic Exchange: 路由键匹配"
    echo "    - Headers Exchange: 头部匹配"
    echo "    - 应用层过滤: 消息内容过滤"
    echo ""
    echo "  示例:"
    echo "    channel.queue_bind("
    echo "        exchange='orders',"
    echo "        queue='order-created',"
    echo "        routing_key='order.created'"
    echo "    )"
}

case $MQ_TYPE in
    kafka)
        test_kafka_filter
        ;;
    nats)
        test_nats_filter
        ;;
    rabbitmq)
        test_rabbitmq_filter
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息过滤测试完成！"
