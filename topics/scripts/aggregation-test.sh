#!/bin/bash
# 消息聚合测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
AGGREGATION_TYPE=${2:-"batch"}

echo "=== 消息聚合测试 ==="
echo "系统: $MQ_TYPE"
echo "聚合类型: $AGGREGATION_TYPE"
echo ""

test_kafka_aggregation() {
    echo "Kafka聚合测试:"
    echo "  聚合方式:"
    echo "    - Producer批处理（batch.size + linger.ms）"
    echo "    - Consumer批量消费"
    echo "    - Kafka Streams聚合"
    echo ""
    echo "  当前测试: $AGGREGATION_TYPE"
    case $AGGREGATION_TYPE in
        batch)
            echo "    - 批次大小: 16384字节"
            echo "    - 等待时间: 10毫秒"
            echo "    - 自动聚合发送"
            ;;
        consumer)
            echo "    - 批量消费: poll()获取多条消息"
            echo "    - 批量处理: 应用层聚合处理"
            ;;
        streams)
            echo "    - Kafka Streams聚合"
            echo "    - 窗口聚合: 时间窗口/滑动窗口"
            ;;
    esac
}

test_nats_aggregation() {
    echo "NATS聚合测试:"
    echo "  聚合方式:"
    echo "    - 批量发布（Flush）"
    echo "    - 批量订阅处理"
    echo "    - JetStream聚合"
    echo ""
    echo "  当前测试: $AGGREGATION_TYPE"
}

test_rabbitmq_aggregation() {
    echo "RabbitMQ聚合测试:"
    echo "  聚合方式:"
    echo "    - 批量发布"
    echo "    - 批量消费"
    echo "    - 队列批量处理"
    echo ""
    echo "  当前测试: $AGGREGATION_TYPE"
}

case $MQ_TYPE in
    kafka)
        test_kafka_aggregation
        ;;
    nats)
        test_nats_aggregation
        ;;
    rabbitmq)
        test_rabbitmq_aggregation
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [aggregation_type]"
        exit 1
        ;;
esac

echo ""
echo "--- 聚合建议 ---"
echo "1. 合理设置批次大小（平衡吞吐量和延迟）"
echo "2. 使用时间窗口控制聚合"
echo "3. 监控聚合性能"
echo "4. 优化内存使用"
echo "5. 考虑消息顺序"

echo ""
echo "消息聚合测试完成！"
