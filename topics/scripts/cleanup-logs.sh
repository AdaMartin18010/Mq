#!/bin/bash
# 日志清理脚本

set -e

MQ_TYPE=${1:-"all"}
RETENTION_DAYS=${2:-7}

echo "=== 清理消息队列日志 ==="
echo "保留天数: $RETENTION_DAYS"
echo ""

cleanup_kafka_logs() {
    echo "清理Kafka日志..."
    
    if [ -d "kafka_*/logs" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        find "$KAFKA_DIR/logs" -name "*.log" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
        echo "  ✅ Kafka日志已清理（保留${RETENTION_DAYS}天）"
    else
        echo "  ⚠️  未找到Kafka日志目录"
    fi
}

cleanup_nats_logs() {
    echo "清理NATS日志..."
    
    if [ -f "/var/log/nats-server.log" ]; then
        find /var/log -name "*nats*" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
        echo "  ✅ NATS日志已清理（保留${RETENTION_DAYS}天）"
    else
        echo "  ⚠️  NATS日志通常输出到stdout/stderr"
    fi
}

cleanup_rabbitmq_logs() {
    echo "清理RabbitMQ日志..."
    
    if [ -d "/var/log/rabbitmq" ]; then
        find /var/log/rabbitmq -name "*.log" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null
        echo "  ✅ RabbitMQ日志已清理（保留${RETENTION_DAYS}天）"
    elif docker ps | grep -q rabbitmq; then
        docker exec rabbitmq find /var/log/rabbitmq -name "*.log" -type f -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
        echo "  ✅ RabbitMQ日志已清理（保留${RETENTION_DAYS}天）"
    else
        echo "  ⚠️  未找到RabbitMQ日志"
    fi
}

case $MQ_TYPE in
    kafka)
        cleanup_kafka_logs
        ;;
    nats)
        cleanup_nats_logs
        ;;
    rabbitmq)
        cleanup_rabbitmq_logs
        ;;
    all)
        cleanup_kafka_logs
        cleanup_nats_logs
        cleanup_rabbitmq_logs
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all] [retention_days]"
        exit 1
        ;;
esac

echo ""
echo "日志清理完成！"
