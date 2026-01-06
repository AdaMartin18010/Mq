#!/bin/bash
# 死信队列监控脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 死信队列监控 ==="

monitor_kafka_dlq() {
    echo "Kafka死信队列监控:"
    
    if command -v kafka-topics.sh &> /dev/null; then
        DLQ_TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | grep -E "^dlq-|^dead-letter" | wc -l)
        echo "  死信Topic数量: $DLQ_TOPICS"
        
        if [ "$DLQ_TOPICS" -gt 0 ]; then
            kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | grep -E "^dlq-|^dead-letter" | \
                while read topic; do
                    echo "    - $topic"
                done
        fi
    else
        echo "  ⚠️  需要kafka-topics.sh工具"
    fi
}

monitor_nats_dlq() {
    echo "NATS死信队列监控:"
    echo "  ⚠️  NATS Core模式无死信队列"
    echo "  JetStream模式需检查Stream配置"
}

monitor_rabbitmq_dlq() {
    echo "RabbitMQ死信队列监控:"
    
    if docker ps | grep -q rabbitmq; then
        DLQ_QUEUES=$(docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | \
            grep -E "dlq|dead-letter" | wc -l)
        echo "  死信队列数量: $DLQ_QUEUES"
        
        if [ "$DLQ_QUEUES" -gt 0 ]; then
            docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | \
                grep -E "dlq|dead-letter" | \
                while read line; do
                    echo "    - $line"
                done
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        DLQ_QUEUES=$(rabbitmqctl list_queues name messages 2>/dev/null | \
            grep -E "dlq|dead-letter" | wc -l)
        echo "  死信队列数量: $DLQ_QUEUES"
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        monitor_kafka_dlq
        ;;
    nats)
        monitor_nats_dlq
        ;;
    rabbitmq)
        monitor_rabbitmq_dlq
        ;;
    all)
        monitor_kafka_dlq
        echo ""
        monitor_nats_dlq
        echo ""
        monitor_rabbitmq_dlq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "死信队列监控完成！"
