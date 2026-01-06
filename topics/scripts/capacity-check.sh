#!/bin/bash
# 容量检查脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列容量检查 ==="

check_kafka_capacity() {
    echo "检查Kafka容量..."
    
    if [ -d "kafka_*/logs" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        DISK_USAGE=$(df -h "$KAFKA_DIR/logs" | tail -1 | awk '{print $5}' | sed 's/%//')
        
        if [ "$DISK_USAGE" -gt 90 ]; then
            echo "  ⚠️  磁盘使用率过高: ${DISK_USAGE}%"
        elif [ "$DISK_USAGE" -gt 80 ]; then
            echo "  ⚠️  磁盘使用率较高: ${DISK_USAGE}%"
        else
            echo "  ✅ 磁盘使用率正常: ${DISK_USAGE}%"
        fi
        
        # 检查Topic数量
        if command -v kafka-topics.sh &> /dev/null; then
            TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "  Topics数量: $TOPICS"
        fi
    else
        echo "  ⚠️  未找到Kafka日志目录"
    fi
}

check_nats_capacity() {
    echo "检查NATS容量..."
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        MEM=$(curl -s http://localhost:8222/varz | grep -o '"mem":[0-9]*' | cut -d: -f2)
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        
        if [ -n "$MEM" ] && [ "$MEM" -gt 8589934592 ]; then  # 8GB
            echo "  ⚠️  内存使用较高: $((MEM / 1024 / 1024 / 1024))GB"
        else
            echo "  ✅ 内存使用正常: ${MEM:-0} bytes"
        fi
        
        if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" -gt 50000 ]; then
            echo "  ⚠️  连接数较多: $CONNECTIONS"
        else
            echo "  ✅ 连接数正常: ${CONNECTIONS:-0}"
        fi
    else
        echo "  ⚠️  NATS监控端口不可用"
    fi
}

check_rabbitmq_capacity() {
    echo "检查RabbitMQ容量..."
    
    if docker ps | grep -q rabbitmq; then
        QUEUES=$(docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | wc -l)
        TOTAL_MSGS=$(docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | \
            awk '{sum+=$2} END {print sum}')
        
        echo "  队列数量: $QUEUES"
        echo "  总消息数: ${TOTAL_MSGS:-0}"
        
        if [ -n "$TOTAL_MSGS" ] && [ "$TOTAL_MSGS" -gt 1000000 ]; then
            echo "  ⚠️  消息积压较多"
        fi
    else
        echo "  ⚠️  RabbitMQ未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_capacity
        ;;
    nats)
        check_nats_capacity
        ;;
    rabbitmq)
        check_rabbitmq_capacity
        ;;
    all)
        check_kafka_capacity
        echo ""
        check_nats_capacity
        echo ""
        check_rabbitmq_capacity
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "容量检查完成！"
