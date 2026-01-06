#!/bin/bash
# 备份验证脚本

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

echo "=== 备份验证 ==="
echo "备份目录: $BACKUP_DIR"
echo ""

verify_kafka_backup() {
    echo "验证Kafka备份..."
    
    if [ -f "$BACKUP_DIR/kafka_config.tar.gz" ]; then
        if tar -tzf "$BACKUP_DIR/kafka_config.tar.gz" &> /dev/null; then
            echo "  ✅ Kafka配置备份有效"
            FILES=$(tar -tzf "$BACKUP_DIR/kafka_config.tar.gz" | wc -l)
            echo "    包含文件数: $FILES"
        else
            echo "  ❌ Kafka配置备份损坏"
        fi
    else
        echo "  ⚠️  未找到Kafka备份"
    fi
}

verify_nats_backup() {
    echo "验证NATS备份..."
    
    if [ -f "$BACKUP_DIR/nats-server.conf" ]; then
        if [ -s "$BACKUP_DIR/nats-server.conf" ]; then
            echo "  ✅ NATS配置备份有效"
            LINES=$(wc -l < "$BACKUP_DIR/nats-server.conf")
            echo "    配置行数: $LINES"
        else
            echo "  ❌ NATS配置备份为空"
        fi
    else
        echo "  ⚠️  未找到NATS备份"
    fi
}

verify_rabbitmq_backup() {
    echo "验证RabbitMQ备份..."
    
    if [ -f "$BACKUP_DIR/rabbitmq_definitions.json" ]; then
        if [ -s "$BACKUP_DIR/rabbitmq_definitions.json" ]; then
            if python3 -m json.tool "$BACKUP_DIR/rabbitmq_definitions.json" &> /dev/null; then
                echo "  ✅ RabbitMQ定义备份有效（JSON格式正确）"
            else
                echo "  ❌ RabbitMQ定义备份JSON格式错误"
            fi
        else
            echo "  ❌ RabbitMQ定义备份为空"
        fi
    else
        echo "  ⚠️  未找到RabbitMQ备份"
    fi
}

verify_kafka_backup
echo ""
verify_nats_backup
echo ""
verify_rabbitmq_backup

echo ""
echo "备份验证完成！"
