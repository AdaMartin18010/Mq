#!/bin/bash
# 消息队列停止脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列停止 ==="

stop_kafka() {
    echo "停止Kafka..."
    if pgrep -f "kafka.Kafka" > /dev/null; then
        pkill -f "kafka.Kafka"
        echo "✅ Kafka已停止"
    else
        echo "ℹ️  Kafka未运行"
    fi
}

stop_nats() {
    echo "停止NATS..."
    if pgrep -f "nats-server" > /dev/null; then
        pkill -f "nats-server"
        echo "✅ NATS已停止"
    else
        echo "ℹ️  NATS未运行"
    fi
}

stop_rabbitmq() {
    echo "停止RabbitMQ..."
    if docker ps | grep -q rabbitmq; then
        docker stop rabbitmq
        echo "✅ RabbitMQ已停止"
    elif pgrep -f "beam.smp.*rabbit" > /dev/null; then
        rabbitmqctl stop
        echo "✅ RabbitMQ已停止"
    else
        echo "ℹ️  RabbitMQ未运行"
    fi
}

stop_redis() {
    echo "停止Redis..."
    if pgrep -f "redis-server" > /dev/null; then
        pkill -f "redis-server"
        echo "✅ Redis已停止"
    else
        echo "ℹ️  Redis未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        stop_kafka
        ;;
    nats)
        stop_nats
        ;;
    rabbitmq)
        stop_rabbitmq
        ;;
    redis)
        stop_redis
        ;;
    all)
        stop_kafka
        stop_nats
        stop_rabbitmq
        stop_redis
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo "停止完成！"
