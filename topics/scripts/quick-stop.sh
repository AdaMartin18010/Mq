#!/bin/bash
# 快速停止脚本（一键停止所有消息队列系统）

set -e

echo "=== 消息队列系统快速停止 ==="
echo ""

stop_kafka() {
    echo "停止Kafka..."
    if [ -f "scripts/stop-kafka.sh" ]; then
        ./scripts/stop-kafka.sh
    elif [ -d "kafka_*" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        "$KAFKA_DIR/bin/kafka-server-stop.sh" 2>/dev/null || pkill -f kafka-server-start
        echo "  ✅ Kafka已停止"
    else
        echo "  ⚠️  未找到Kafka"
    fi
}

stop_nats() {
    echo "停止NATS..."
    if pgrep -f nats-server > /dev/null; then
        pkill -f nats-server
        echo "  ✅ NATS已停止"
    else
        echo "  ⚠️  NATS未运行"
    fi
}

stop_rabbitmq() {
    echo "停止RabbitMQ..."
    if docker ps | grep -q rabbitmq; then
        docker stop rabbitmq
        echo "  ✅ RabbitMQ已停止"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl stop
        echo "  ✅ RabbitMQ已停止"
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

stop_redis() {
    echo "停止Redis..."
    if docker ps | grep -q redis; then
        docker stop redis
        echo "  ✅ Redis已停止"
    elif pgrep -f redis-server > /dev/null; then
        pkill -f redis-server
        echo "  ✅ Redis已停止"
    else
        echo "  ⚠️  Redis未运行"
    fi
}

stop_kafka
sleep 1
stop_nats
sleep 1
stop_rabbitmq
sleep 1
stop_redis

echo ""
echo "快速停止完成！"
