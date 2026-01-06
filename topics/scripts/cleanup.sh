#!/bin/bash
# 消息队列清理脚本

set -e

MQ_TYPE=${1:-"kafka"}
ACTION=${2:-"logs"}

echo "=== 消息队列清理工具 ==="

cleanup_kafka_logs() {
    echo "清理Kafka日志..."
    KAFKA_DIR=${KAFKA_DIR:-"kafka_2.13-3.5.0"}
    if [ -d "$KAFKA_DIR/logs" ]; then
        find "$KAFKA_DIR/logs" -name "*.log" -type f -mtime +7 -delete
        echo "✅ 已清理7天前的日志文件"
    fi
}

cleanup_kafka_topics() {
    echo "清理Kafka旧数据..."
    if command -v kafka-topics.sh &> /dev/null; then
        echo "使用kafka-configs.sh设置保留策略"
        echo "示例: kafka-configs.sh --alter --topic test-topic --add-config retention.ms=86400000"
    fi
}

cleanup_nats_logs() {
    echo "清理NATS日志..."
    if [ -d "/var/log/nats" ]; then
        find /var/log/nats -name "*.log" -type f -mtime +7 -delete
        echo "✅ 已清理7天前的日志文件"
    fi
}

cleanup_rabbitmq_logs() {
    echo "清理RabbitMQ日志..."
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq find /var/log/rabbitmq -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
        echo "✅ 已清理7天前的日志文件"
    fi
}

case $MQ_TYPE in
    kafka)
        case $ACTION in
            logs)
                cleanup_kafka_logs
                ;;
            topics)
                cleanup_kafka_topics
                ;;
            *)
                cleanup_kafka_logs
                cleanup_kafka_topics
                ;;
        esac
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
        echo "用法: $0 [kafka|nats|rabbitmq|all] [logs|topics]"
        exit 1
        ;;
esac

echo "清理完成！"
