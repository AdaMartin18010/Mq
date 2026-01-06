#!/bin/bash
# 消息队列启动脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列启动 ==="

start_kafka() {
    echo "启动Kafka..."
    KAFKA_DIR=$(ls -d kafka_* 2>/dev/null | head -1)
    if [ -n "$KAFKA_DIR" ]; then
        cd "$KAFKA_DIR"
        if [ ! -f "config/kraft/server.properties" ]; then
            # 传统模式，需要ZooKeeper
            if ! pgrep -f "QuorumPeerMain" > /dev/null; then
                bin/zookeeper-server-start.sh config/zookeeper.properties &
                sleep 3
            fi
        fi
        bin/kafka-server-start.sh config/server.properties &
        echo "✅ Kafka已启动"
    else
        echo "❌ 未找到Kafka目录"
    fi
}

start_nats() {
    echo "启动NATS..."
    if [ -f "nats-server" ]; then
        ./nats-server &
        echo "✅ NATS已启动"
    elif command -v nats-server &> /dev/null; then
        nats-server &
        echo "✅ NATS已启动"
    else
        echo "❌ 未找到NATS Server"
    fi
}

start_rabbitmq() {
    echo "启动RabbitMQ..."
    if command -v docker &> /dev/null; then
        if ! docker ps | grep -q rabbitmq; then
            docker start rabbitmq 2>/dev/null || \
            docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 \
                -e RABBITMQ_DEFAULT_USER=admin \
                -e RABBITMQ_DEFAULT_PASS=admin \
                rabbitmq:3-management
            echo "✅ RabbitMQ已启动"
        else
            echo "ℹ️  RabbitMQ已在运行"
        fi
    else
        echo "❌ 需要Docker或RabbitMQ Server"
    fi
}

start_redis() {
    echo "启动Redis..."
    if command -v redis-server &> /dev/null; then
        if ! pgrep -f "redis-server" > /dev/null; then
            redis-server --daemonize yes
            echo "✅ Redis已启动"
        else
            echo "ℹ️  Redis已在运行"
        fi
    else
        echo "❌ 未找到Redis Server"
    fi
}

case $MQ_TYPE in
    kafka)
        start_kafka
        ;;
    nats)
        start_nats
        ;;
    rabbitmq)
        start_rabbitmq
        ;;
    redis)
        start_redis
        ;;
    all)
        start_kafka
        sleep 2
        start_nats
        sleep 1
        start_rabbitmq
        sleep 1
        start_redis
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo "启动完成！"
