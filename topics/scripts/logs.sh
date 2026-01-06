#!/bin/bash
# 消息队列日志查看脚本

set -e

MQ_TYPE=${1:-"kafka"}
LINES=${2:-100}

echo "=== 消息队列日志查看 ==="

view_kafka_logs() {
    echo "Kafka日志（最近${LINES}行）:"
    
    KAFKA_DIR=$(ls -d kafka_* 2>/dev/null | head -1)
    if [ -n "$KAFKA_DIR" ] && [ -d "$KAFKA_DIR/logs" ]; then
        find "$KAFKA_DIR/logs" -name "server.log" -type f -exec tail -n $LINES {} \;
    else
        echo "❌ 未找到Kafka日志目录"
    fi
}

view_nats_logs() {
    echo "NATS日志（最近${LINES}行）:"
    
    if docker ps | grep -q nats; then
        docker logs --tail $LINES $(docker ps | grep nats | awk '{print $1}')
    elif [ -f "/var/log/nats/nats.log" ]; then
        tail -n $LINES /var/log/nats/nats.log
    else
        echo "❌ 未找到NATS日志"
    fi
}

view_rabbitmq_logs() {
    echo "RabbitMQ日志（最近${LINES}行）:"
    
    if docker ps | grep -q rabbitmq; then
        docker logs --tail $LINES $(docker ps | grep rabbitmq | awk '{print $1}')
    elif [ -f "/var/log/rabbitmq/rabbit@*.log" ]; then
        tail -n $LINES /var/log/rabbitmq/rabbit@*.log
    else
        echo "❌ 未找到RabbitMQ日志"
    fi
}

case $MQ_TYPE in
    kafka)
        view_kafka_logs
        ;;
    nats)
        view_nats_logs
        ;;
    rabbitmq)
        view_rabbitmq_logs
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [lines]"
        exit 1
        ;;
esac
