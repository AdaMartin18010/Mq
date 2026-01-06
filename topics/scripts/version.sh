#!/bin/bash
# 消息队列版本检查脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列版本信息 ==="

check_kafka_version() {
    echo "Kafka版本:"
    
    if command -v kafka-server-start.sh &> /dev/null; then
        KAFKA_DIR=$(dirname $(dirname $(which kafka-server-start.sh)))
        if [ -f "$KAFKA_DIR/bin/kafka-run-class.sh" ]; then
            VERSION=$(grep -o "kafka_[0-9.]*" "$KAFKA_DIR/bin/kafka-run-class.sh" 2>/dev/null | head -1 | cut -d_ -f2 || echo "未知")
            echo "  Kafka: $VERSION"
        fi
    elif [ -d "kafka_*" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        VERSION=$(echo "$KAFKA_DIR" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" || echo "未知")
        echo "  Kafka: $VERSION"
    else
        echo "  ❌ 未找到Kafka"
    fi
}

check_nats_version() {
    echo "NATS版本:"
    
    if command -v nats-server &> /dev/null; then
        VERSION=$(nats-server -v 2>&1 | grep -o "v[0-9.]*" | head -1 || echo "未知")
        echo "  NATS: $VERSION"
    elif [ -f "nats-server" ]; then
        VERSION=$(./nats-server -v 2>&1 | grep -o "v[0-9.]*" | head -1 || echo "未知")
        echo "  NATS: $VERSION"
    else
        echo "  ❌ 未找到NATS"
    fi
}

check_rabbitmq_version() {
    echo "RabbitMQ版本:"
    
    if docker ps | grep -q rabbitmq; then
        VERSION=$(docker exec rabbitmq rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  RabbitMQ: $VERSION"
    elif command -v rabbitmqctl &> /dev/null; then
        VERSION=$(rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  RabbitMQ: $VERSION"
    else
        echo "  ❌ 未找到RabbitMQ"
    fi
}

check_redis_version() {
    echo "Redis版本:"
    
    if command -v redis-cli &> /dev/null; then
        VERSION=$(redis-cli info server | grep "redis_version" | cut -d: -f2 | tr -d '\r' || echo "未知")
        echo "  Redis: $VERSION"
    else
        echo "  ❌ 未找到Redis"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_version
        ;;
    nats)
        check_nats_version
        ;;
    rabbitmq)
        check_rabbitmq_version
        ;;
    redis)
        check_redis_version
        ;;
    all)
        check_kafka_version
        echo ""
        check_nats_version
        echo ""
        check_rabbitmq_version
        echo ""
        check_redis_version
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo ""
echo "版本检查完成！"
