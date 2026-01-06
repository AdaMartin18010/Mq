#!/bin/bash
# 消息队列重启脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列重启 ==="

restart_kafka() {
    echo "重启Kafka..."
    
    # 停止Kafka
    if pgrep -f "kafka.Kafka" > /dev/null; then
        pkill -f "kafka.Kafka"
        sleep 2
    fi
    
    # 启动Kafka
    KAFKA_DIR=$(ls -d kafka_* 2>/dev/null | head -1)
    if [ -n "$KAFKA_DIR" ]; then
        cd "$KAFKA_DIR"
        bin/kafka-server-start.sh config/server.properties &
        echo "✅ Kafka已重启"
    else
        echo "❌ 未找到Kafka目录"
    fi
}

restart_nats() {
    echo "重启NATS..."
    
    # 停止NATS
    if pgrep -f "nats-server" > /dev/null; then
        pkill -f "nats-server"
        sleep 1
    fi
    
    # 启动NATS
    if [ -f "nats-server" ]; then
        ./nats-server &
        echo "✅ NATS已重启"
    elif command -v nats-server &> /dev/null; then
        nats-server &
        echo "✅ NATS已重启"
    else
        echo "❌ 未找到NATS Server"
    fi
}

restart_rabbitmq() {
    echo "重启RabbitMQ..."
    
    if docker ps | grep -q rabbitmq; then
        docker restart rabbitmq
        echo "✅ RabbitMQ已重启"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl stop_app
        rabbitmqctl start_app
        echo "✅ RabbitMQ已重启"
    else
        echo "❌ 未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        restart_kafka
        ;;
    nats)
        restart_nats
        ;;
    rabbitmq)
        restart_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo "重启完成！"
