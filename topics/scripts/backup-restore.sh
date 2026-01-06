#!/bin/bash
# 消息队列备份和恢复脚本

set -e

ACTION=${1:-"backup"}
MQ_TYPE=${2:-"kafka"}

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

backup_kafka() {
    echo "备份Kafka数据..."
    
    KAFKA_DIR=${KAFKA_DIR:-"kafka_2.13-3.5.0"}
    
    if [ -d "$KAFKA_DIR/logs" ]; then
        tar -czf "$BACKUP_DIR/kafka_backup_$DATE.tar.gz" \
            "$KAFKA_DIR/logs" \
            "$KAFKA_DIR/config" 2>/dev/null || true
        echo "✅ Kafka备份完成: $BACKUP_DIR/kafka_backup_$DATE.tar.gz"
    else
        echo "❌ 未找到Kafka目录"
        return 1
    fi
}

restore_kafka() {
    echo "恢复Kafka数据..."
    
    BACKUP_FILE=${3:-$(ls -t "$BACKUP_DIR"/kafka_backup_*.tar.gz 2>/dev/null | head -1)}
    
    if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ 未找到备份文件"
        return 1
    fi
    
    KAFKA_DIR=${KAFKA_DIR:-"kafka_2.13-3.5.0"}
    
    echo "从 $BACKUP_FILE 恢复..."
    tar -xzf "$BACKUP_FILE" -C .
    echo "✅ Kafka恢复完成"
}

backup_rabbitmq() {
    echo "备份RabbitMQ数据..."
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl export_definitions \
            "$BACKUP_DIR/rabbitmq_definitions_$DATE.json" 2>/dev/null || true
        echo "✅ RabbitMQ备份完成: $BACKUP_DIR/rabbitmq_definitions_$DATE.json"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl export_definitions \
            "$BACKUP_DIR/rabbitmq_definitions_$DATE.json" 2>/dev/null || true
        echo "✅ RabbitMQ备份完成"
    else
        echo "❌ 未找到RabbitMQ"
        return 1
    fi
}

restore_rabbitmq() {
    echo "恢复RabbitMQ数据..."
    
    BACKUP_FILE=${3:-$(ls -t "$BACKUP_DIR"/rabbitmq_definitions_*.json 2>/dev/null | head -1)}
    
    if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ 未找到备份文件"
        return 1
    fi
    
    if docker ps | grep -q rabbitmq; then
        docker cp "$BACKUP_FILE" rabbitmq:/tmp/definitions.json
        docker exec rabbitmq rabbitmqctl import_definitions /tmp/definitions.json
        echo "✅ RabbitMQ恢复完成"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl import_definitions "$BACKUP_FILE"
        echo "✅ RabbitMQ恢复完成"
    else
        echo "❌ 未找到RabbitMQ"
        return 1
    fi
}

case $ACTION in
    backup)
        case $MQ_TYPE in
            kafka)
                backup_kafka
                ;;
            rabbitmq)
                backup_rabbitmq
                ;;
            *)
                echo "用法: $0 backup [kafka|rabbitmq]"
                exit 1
                ;;
        esac
        ;;
    restore)
        case $MQ_TYPE in
            kafka)
                restore_kafka "$@"
                ;;
            rabbitmq)
                restore_rabbitmq "$@"
                ;;
            *)
                echo "用法: $0 restore [kafka|rabbitmq] [backup_file]"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "用法: $0 [backup|restore] [kafka|rabbitmq] [backup_file]"
        exit 1
        ;;
esac
