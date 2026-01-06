#!/bin/bash
# 所有消息队列系统恢复脚本

set -e

BACKUP_DIR=${1:-""}

if [ -z "$BACKUP_DIR" ]; then
    echo "用法: $0 <backup_directory>"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "错误: 备份目录不存在: $BACKUP_DIR"
    exit 1
fi

echo "=== 消息队列系统恢复 ==="
echo "⚠️  警告：此操作将覆盖现有配置！"
read -p "确认继续？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

restore_kafka() {
    echo "恢复Kafka..."
    
    if [ -f "$BACKUP_DIR/kafka_config.tar.gz" ]; then
        tar -xzf "$BACKUP_DIR/kafka_config.tar.gz" -C . 2>/dev/null
        echo "  ✅ Kafka配置已恢复"
    else
        echo "  ⚠️  未找到Kafka备份"
    fi
}

restore_nats() {
    echo "恢复NATS..."
    
    if [ -f "$BACKUP_DIR/nats-server.conf" ]; then
        cp "$BACKUP_DIR/nats-server.conf" nats-server.conf
        echo "  ✅ NATS配置已恢复"
    else
        echo "  ⚠️  未找到NATS备份"
    fi
}

restore_rabbitmq() {
    echo "恢复RabbitMQ..."
    
    if [ -f "$BACKUP_DIR/rabbitmq_definitions.json" ]; then
        if docker ps | grep -q rabbitmq; then
            docker exec -i rabbitmq rabbitmqctl import_definitions < "$BACKUP_DIR/rabbitmq_definitions.json" 2>/dev/null
            echo "  ✅ RabbitMQ定义已恢复"
        elif command -v rabbitmqctl &> /dev/null; then
            rabbitmqctl import_definitions "$BACKUP_DIR/rabbitmq_definitions.json" 2>/dev/null
            echo "  ✅ RabbitMQ定义已恢复"
        else
            echo "  ⚠️  未找到RabbitMQ"
        fi
    else
        echo "  ⚠️  未找到RabbitMQ备份"
    fi
}

restore_kafka
restore_nats
restore_rabbitmq

echo ""
echo "恢复完成！"
