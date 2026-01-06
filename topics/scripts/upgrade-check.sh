#!/bin/bash
# 版本升级检查脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列版本升级检查 ==="

check_kafka_upgrade() {
    echo "检查Kafka升级..."
    
    if command -v kafka-broker-api-versions.sh &> /dev/null; then
        VERSION=$(kafka-broker-api-versions.sh --bootstrap-server localhost:9092 2>/dev/null | \
            head -1 | grep -o "kafka_[0-9.]*" | head -1 | cut -d_ -f2 || echo "未知")
        echo "  当前版本: $VERSION"
        echo "  ⚠️  检查Kafka官网获取最新版本: https://kafka.apache.org/downloads"
    else
        echo "  ⚠️  未找到Kafka工具"
    fi
}

check_nats_upgrade() {
    echo "检查NATS升级..."
    
    if command -v nats-server &> /dev/null; then
        VERSION=$(nats-server -v 2>&1 | grep -o "v[0-9.]*" | head -1 || echo "未知")
        echo "  当前版本: $VERSION"
        echo "  ⚠️  检查NATS官网获取最新版本: https://github.com/nats-io/nats-server/releases"
    else
        echo "  ⚠️  未找到NATS"
    fi
}

check_rabbitmq_upgrade() {
    echo "检查RabbitMQ升级..."
    
    if docker ps | grep -q rabbitmq; then
        VERSION=$(docker exec rabbitmq rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  当前版本: $VERSION"
        echo "  ⚠️  检查RabbitMQ官网获取最新版本: https://www.rabbitmq.com/download.html"
    elif command -v rabbitmqctl &> /dev/null; then
        VERSION=$(rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  当前版本: $VERSION"
        echo "  ⚠️  检查RabbitMQ官网获取最新版本: https://www.rabbitmq.com/download.html"
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_upgrade
        ;;
    nats)
        check_nats_upgrade
        ;;
    rabbitmq)
        check_rabbitmq_upgrade
        ;;
    all)
        check_kafka_upgrade
        echo ""
        check_nats_upgrade
        echo ""
        check_rabbitmq_upgrade
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "升级检查完成！"
