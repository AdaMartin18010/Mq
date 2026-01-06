#!/bin/bash
# 消息队列日志实时查看脚本

set -e

MQ_TYPE=${1:-"kafka"}
LINES=${2:-100}

echo "=== 消息队列日志查看 ==="

tail_kafka_logs() {
    echo "Kafka日志（最后${LINES}行）:"
    
    if [ -d "kafka_*/logs" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        tail -n $LINES "$KAFKA_DIR/logs/server.log" 2>/dev/null || \
        tail -n $LINES "$KAFKA_DIR/logs/kafkaServer.out" 2>/dev/null || \
        echo "  ⚠️  未找到日志文件"
    else
        echo "  ⚠️  未找到Kafka目录"
    fi
}

tail_nats_logs() {
    echo "NATS日志:"
    echo "  ⚠️  NATS日志通常输出到stdout/stderr"
    echo "  使用: journalctl -u nats-server 或 docker logs <container>"
}

tail_rabbitmq_logs() {
    echo "RabbitMQ日志（最后${LINES}行）:"
    
    if docker ps | grep -q rabbitmq; then
        docker logs --tail $LINES rabbitmq 2>/dev/null || echo "  ⚠️  无法获取日志"
    elif [ -f "/var/log/rabbitmq/rabbit@*.log" ]; then
        tail -n $LINES /var/log/rabbitmq/rabbit@*.log 2>/dev/null || echo "  ⚠️  未找到日志文件"
    else
        echo "  ⚠️  未找到RabbitMQ日志"
    fi
}

case $MQ_TYPE in
    kafka)
        tail_kafka_logs
        ;;
    nats)
        tail_nats_logs
        ;;
    rabbitmq)
        tail_rabbitmq_logs
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [lines]"
        exit 1
        ;;
esac
