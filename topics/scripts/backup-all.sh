#!/bin/bash
# 所有消息队列系统备份脚本

set -e

BACKUP_DIR=${1:-"backup_$(date +%Y%m%d_%H%M%S)"}

echo "=== 消息队列系统备份 ==="
mkdir -p "$BACKUP_DIR"

backup_kafka() {
    echo "备份Kafka..."
    
    if [ -d "kafka_*/config" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        tar -czf "$BACKUP_DIR/kafka_config.tar.gz" "$KAFKA_DIR/config" 2>/dev/null
        echo "  ✅ Kafka配置已备份"
    else
        echo "  ⚠️  未找到Kafka配置"
    fi
}

backup_nats() {
    echo "备份NATS..."
    
    if [ -f "nats-server.conf" ]; then
        cp nats-server.conf "$BACKUP_DIR/nats-server.conf"
        echo "  ✅ NATS配置已备份"
    else
        echo "  ⚠️  未找到NATS配置"
    fi
}

backup_rabbitmq() {
    echo "备份RabbitMQ..."
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl export_definitions "$BACKUP_DIR/rabbitmq_definitions.json" 2>/dev/null
        echo "  ✅ RabbitMQ定义已备份"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl export_definitions "$BACKUP_DIR/rabbitmq_definitions.json" 2>/dev/null
        echo "  ✅ RabbitMQ定义已备份"
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

backup_kafka
backup_nats
backup_rabbitmq

echo ""
echo "备份完成！备份目录: $BACKUP_DIR"
