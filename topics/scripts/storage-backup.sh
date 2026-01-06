#!/bin/bash
# 消息存储备份脚本

set -e

BACKUP_TYPE=${1:-"full"}  # full/incremental/snapshot
BACKUP_DIR=${2:-"./backups"}
DATE=$(date +%Y%m%d_%H%M%S)

echo "=== 消息存储备份 ==="
echo "备份类型: $BACKUP_TYPE"
echo "备份目录: $BACKUP_DIR"
echo "备份时间: $DATE"
echo ""

mkdir -p "$BACKUP_DIR"

backup_kafka() {
    echo "备份Kafka存储..."
    
    KAFKA_LOG_DIRS=$(grep "log.dirs" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | \
        cut -d'=' -f2 | cut -d',' -f1)
    
    if [ -n "$KAFKA_LOG_DIRS" ] && [ -d "$KAFKA_LOG_DIRS" ]; then
        BACKUP_FILE="$BACKUP_DIR/kafka_${BACKUP_TYPE}_${DATE}.tar.gz"
        echo "  备份到: $BACKUP_FILE"
        tar -czf "$BACKUP_FILE" -C "$(dirname $KAFKA_LOG_DIRS)" "$(basename $KAFKA_LOG_DIRS)" 2>/dev/null || true
        echo "  ✅ Kafka备份完成"
    else
        echo "  ⚠️  Kafka存储路径未找到"
    fi
}

backup_nats() {
    echo "备份NATS存储..."
    
    if docker ps | grep -q nats; then
        BACKUP_FILE="$BACKUP_DIR/nats_${BACKUP_TYPE}_${DATE}.tar.gz"
        echo "  备份到: $BACKUP_FILE"
        docker exec nats tar -czf /tmp/nats_backup.tar.gz /data 2>/dev/null || true
        docker cp nats:/tmp/nats_backup.tar.gz "$BACKUP_FILE" 2>/dev/null || true
        docker exec nats rm /tmp/nats_backup.tar.gz 2>/dev/null || true
        echo "  ✅ NATS备份完成"
    else
        echo "  ⚠️  NATS容器未运行"
    fi
}

backup_rabbitmq() {
    echo "备份RabbitMQ存储..."
    
    if docker ps | grep -q rabbitmq; then
        BACKUP_FILE="$BACKUP_DIR/rabbitmq_${BACKUP_TYPE}_${DATE}.tar.gz"
        echo "  备份到: $BACKUP_FILE"
        docker exec rabbitmq tar -czf /tmp/rabbitmq_backup.tar.gz /var/lib/rabbitmq/mnesia 2>/dev/null || true
        docker cp rabbitmq:/tmp/rabbitmq_backup.tar.gz "$BACKUP_FILE" 2>/dev/null || true
        docker exec rabbitmq rm /tmp/rabbitmq_backup.tar.gz 2>/dev/null || true
        echo "  ✅ RabbitMQ备份完成"
    elif command -v rabbitmqctl &> /dev/null; then
        RABBITMQ_DATA_DIR=$(rabbitmqctl environment 2>/dev/null | \
            grep "MNESIA_BASE" | awk '{print $2}' | tr -d '"')
        if [ -n "$RABBITMQ_DATA_DIR" ] && [ -d "$RABBITMQ_DATA_DIR" ]; then
            BACKUP_FILE="$BACKUP_DIR/rabbitmq_${BACKUP_TYPE}_${DATE}.tar.gz"
            echo "  备份到: $BACKUP_FILE"
            tar -czf "$BACKUP_FILE" -C "$(dirname $RABBITMQ_DATA_DIR)" "$(basename $RABBITMQ_DATA_DIR)" 2>/dev/null || true
            echo "  ✅ RabbitMQ备份完成"
        fi
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
}

case $BACKUP_TYPE in
    full)
        backup_kafka
        backup_nats
        backup_rabbitmq
        ;;
    incremental)
        echo "增量备份功能待实现"
        ;;
    snapshot)
        echo "快照备份功能待实现"
        ;;
    *)
        echo "用法: $0 [full|incremental|snapshot] [backup_dir]"
        exit 1
        ;;
esac

echo ""
echo "消息存储备份完成！"
