#!/bin/bash
# 消息队列健康检查脚本

set -e

echo "=== 消息队列健康检查 ==="

MQ_TYPE=${1:-"kafka"}

check_kafka() {
    echo "检查Kafka健康状态..."
    
    # 检查Broker是否运行
    if ! pgrep -f "kafka.Kafka" > /dev/null; then
        echo "❌ Kafka Broker未运行"
        return 1
    fi
    
    # 检查端口
    if ! nc -z localhost 9092 2>/dev/null; then
        echo "❌ Kafka端口9092不可达"
        return 1
    fi
    
    # 检查Topic
    if command -v kafka-topics.sh &> /dev/null; then
        echo "✅ Kafka运行正常"
        kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | head -5
    else
        echo "✅ Kafka运行正常（无法列出Topic）"
    fi
}

check_nats() {
    echo "检查NATS健康状态..."
    
    # 检查Server是否运行
    if ! pgrep -f "nats-server" > /dev/null; then
        echo "❌ NATS Server未运行"
        return 1
    fi
    
    # 检查HTTP监控端口
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "✅ NATS运行正常"
        curl -s http://localhost:8222/varz | grep -E "connections|in_msgs|out_msgs" | head -3
    else
        echo "❌ NATS监控端口不可达"
        return 1
    fi
}

check_rabbitmq() {
    echo "检查RabbitMQ健康状态..."
    
    # 检查是否运行（Docker）
    if docker ps | grep -q rabbitmq; then
        echo "✅ RabbitMQ运行正常（Docker）"
        docker exec rabbitmq rabbitmqctl status 2>/dev/null | head -5
    elif command -v rabbitmqctl &> /dev/null; then
        if rabbitmqctl status > /dev/null 2>&1; then
            echo "✅ RabbitMQ运行正常"
        else
            echo "❌ RabbitMQ未运行"
            return 1
        fi
    else
        echo "❌ 未找到RabbitMQ"
        return 1
    fi
}

check_redis() {
    echo "检查Redis健康状态..."
    
    if command -v redis-cli &> /dev/null; then
        if redis-cli ping > /dev/null 2>&1; then
            echo "✅ Redis运行正常"
            redis-cli info server | grep -E "redis_version|uptime_in_seconds" | head -2
        else
            echo "❌ Redis未运行"
            return 1
        fi
    else
        echo "❌ 未找到Redis"
        return 1
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka
        ;;
    nats)
        check_nats
        ;;
    rabbitmq)
        check_rabbitmq
        ;;
    redis)
        check_redis
        ;;
    all)
        check_kafka && echo ""
        check_nats && echo ""
        check_rabbitmq && echo ""
        check_redis
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo ""
echo "健康检查完成！"
