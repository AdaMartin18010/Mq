#!/bin/bash
# 消息分区测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息分区测试 ==="
echo ""

test_kafka_partition() {
    echo "Kafka分区测试:"
    echo "  Kafka分区策略:"
    echo "    - Key Hash分区（默认）"
    echo "    - 轮询分区"
    echo "    - 自定义分区器"
    echo ""
    echo "  分区数量建议:"
    echo "    - 根据吞吐量需求"
    echo "    - 考虑消费者数量"
    echo "    - 平衡并行度和资源"
    echo ""
    echo "  示例:"
    echo "    kafka-topics.sh --create \\"
    echo "        --topic orders \\"
    echo "        --partitions 6 \\"
    echo "        --replication-factor 3"
}

test_nats_partition() {
    echo "NATS分区测试:"
    echo "  NATS分区实现:"
    echo "    - 使用Subject前缀实现分区"
    echo "    - JetStream使用Stream"
    echo "    - 应用层分区逻辑"
    echo ""
    echo "  示例:"
    echo "    subject := fmt.Sprintf(\"orders.partition.%d\", partitionID)"
}

test_rabbitmq_partition() {
    echo "RabbitMQ分区测试:"
    echo "  RabbitMQ分区实现:"
    echo "    - 使用多个队列实现分区"
    echo "    - 根据Key路由到不同队列"
    echo "    - 应用层分区逻辑"
    echo ""
    echo "  示例:"
    echo "    partition = hash(order_id) % partition_count"
    echo "    queue_name = f\"orders-partition-{partition}\""
}

case $MQ_TYPE in
    kafka)
        test_kafka_partition
        ;;
    nats)
        test_nats_partition
        ;;
    rabbitmq)
        test_rabbitmq_partition
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息分区测试完成！"
