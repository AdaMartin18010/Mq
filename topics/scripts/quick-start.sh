#!/bin/bash
# 快速启动脚本（一键启动所有消息队列系统）

set -e

echo "=== 消息队列系统快速启动 ==="
echo ""

start_kafka() {
    echo "启动Kafka..."
    if [ -f "scripts/start-kafka.sh" ]; then
        ./scripts/start-kafka.sh
    elif [ -d "kafka_*" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        "$KAFKA_DIR/bin/kafka-server-start.sh" "$KAFKA_DIR/config/server.properties" &
        echo "  ✅ Kafka已启动"
    else
        echo "  ⚠️  未找到Kafka"
    fi
}

start_nats() {
    echo "启动NATS..."
    if command -v nats-server &> /dev/null; then
        nats-server &
        echo "  ✅ NATS已启动"
    elif [ -f "nats-server" ]; then
        ./nats-server &
        echo "  ✅ NATS已启动"
    else
        echo "  ⚠️  未找到NATS"
    fi
}

start_rabbitmq() {
    echo "启动RabbitMQ..."
    if docker ps -a | grep -q rabbitmq; then
        docker start rabbitmq
        echo "  ✅ RabbitMQ已启动"
    elif command -v rabbitmq-server &> /dev/null; then
        rabbitmq-server -detached
        echo "  ✅ RabbitMQ已启动"
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

start_redis() {
    echo "启动Redis..."
    if docker ps -a | grep -q redis; then
        docker start redis
        echo "  ✅ Redis已启动"
    elif command -v redis-server &> /dev/null; then
        redis-server --daemonize yes
        echo "  ✅ Redis已启动"
    else
        echo "  ⚠️  未找到Redis"
    fi
}

start_kafka
sleep 2
start_nats
sleep 2
start_rabbitmq
sleep 2
start_redis

echo ""
echo "等待服务启动..."
sleep 5

echo ""
echo "检查服务状态..."
./scripts/health-check-all.sh

echo ""
echo "快速启动完成！"
