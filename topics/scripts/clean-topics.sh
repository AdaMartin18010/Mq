#!/bin/bash
# 消息队列主题/队列清理脚本

set -e

MQ_TYPE=${1:-"kafka"}
PATTERN=${2:-""}

echo "=== 消息队列主题/队列清理 ==="
echo "⚠️  警告：此操作将删除数据，请谨慎使用！"
read -p "确认继续？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

clean_kafka_topics() {
    echo "清理Kafka Topics..."
    
    if [ -z "$PATTERN" ]; then
        echo "  ❌ 需要指定Topic名称或模式"
        return 1
    fi
    
    if command -v kafka-topics.sh &> /dev/null; then
        kafka-topics.sh --delete --topic "$PATTERN" \
            --bootstrap-server localhost:9092 2>/dev/null
        echo "  ✅ Topic已删除: $PATTERN"
    else
        echo "  ❌ 需要kafka-topics.sh工具"
    fi
}

clean_rabbitmq_queues() {
    echo "清理RabbitMQ Queues..."
    
    if [ -z "$PATTERN" ]; then
        echo "  ❌ 需要指定Queue名称或模式"
        return 1
    fi
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl delete_queue "$PATTERN" 2>/dev/null
        echo "  ✅ Queue已删除: $PATTERN"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl delete_queue "$PATTERN" 2>/dev/null
        echo "  ✅ Queue已删除: $PATTERN"
    else
        echo "  ❌ 未找到RabbitMQ"
    fi
}

clean_redis_streams() {
    echo "清理Redis Streams..."
    
    if [ -z "$PATTERN" ]; then
        echo "  ❌ 需要指定Stream名称或模式"
        return 1
    fi
    
    if command -v redis-cli &> /dev/null; then
        redis-cli DEL "$PATTERN" 2>/dev/null
        echo "  ✅ Stream已删除: $PATTERN"
    else
        echo "  ❌ 未找到redis-cli"
    fi
}

case $MQ_TYPE in
    kafka)
        clean_kafka_topics
        ;;
    rabbitmq)
        clean_rabbitmq_queues
        ;;
    redis)
        clean_redis_streams
        ;;
    *)
        echo "用法: $0 [kafka|rabbitmq|redis] [pattern]"
        exit 1
        ;;
esac

echo "清理完成！"
