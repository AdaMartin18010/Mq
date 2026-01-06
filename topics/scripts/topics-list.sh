#!/bin/bash
# 消息队列主题/队列列表脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列主题/队列列表 ==="

list_kafka_topics() {
    echo "Kafka Topics:"
    
    if command -v kafka-topics.sh &> /dev/null; then
        kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | \
            while read topic; do
                echo "  - $topic"
            done
    else
        echo "  ⚠️  需要kafka-topics.sh工具"
    fi
}

list_nats_subjects() {
    echo "NATS Subjects:"
    echo "  ⚠️  NATS Core模式无持久化主题列表"
    echo "  使用监控端口查看连接和消息统计:"
    echo "  curl http://localhost:8222/varz"
}

list_rabbitmq_queues() {
    echo "RabbitMQ Queues:"
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | \
            head -20 | tail -n +2 | \
            while read line; do
                echo "  - $line"
            done
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl list_queues name messages 2>/dev/null | \
            head -20 | tail -n +2 | \
            while read line; do
                echo "  - $line"
            done
    else
        echo "  ❌ 未找到RabbitMQ"
    fi
}

list_redis_streams() {
    echo "Redis Streams:"
    
    if command -v redis-cli &> /dev/null; then
        redis-cli KEYS "*" 2>/dev/null | grep -E "^[^:]*:" | \
            while read key; do
                TYPE=$(redis-cli TYPE "$key" 2>/dev/null)
                if [ "$TYPE" = "stream" ]; then
                    echo "  - $key"
                fi
            done
    else
        echo "  ❌ 未找到redis-cli"
    fi
}

case $MQ_TYPE in
    kafka)
        list_kafka_topics
        ;;
    nats)
        list_nats_subjects
        ;;
    rabbitmq)
        list_rabbitmq_queues
        ;;
    redis)
        list_redis_streams
        ;;
    all)
        list_kafka_topics
        echo ""
        list_nats_subjects
        echo ""
        list_rabbitmq_queues
        echo ""
        list_redis_streams
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo ""
echo "列表完成！"
