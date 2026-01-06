#!/bin/bash
# 资源使用情况脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列资源使用情况 ==="
echo ""

check_kafka_resources() {
    echo "Kafka资源使用:"
    
    if [ -d "kafka_*/logs" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        DISK_USAGE=$(df -h "$KAFKA_DIR/logs" 2>/dev/null | tail -1 | awk '{print $5}')
        echo "  磁盘使用: $DISK_USAGE"
        
        # 检查进程
        KAFKA_PID=$(pgrep -f kafka-server-start | head -1)
        if [ -n "$KAFKA_PID" ]; then
            MEM=$(ps -p $KAFKA_PID -o rss= 2>/dev/null | awk '{printf "%.2f MB", $1/1024}')
            CPU=$(ps -p $KAFKA_PID -o %cpu= 2>/dev/null)
            echo "  内存使用: $MEM"
            echo "  CPU使用: ${CPU}%"
        fi
    fi
}

check_nats_resources() {
    echo "NATS资源使用:"
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        MEM=$(curl -s http://localhost:8222/varz | grep -o '"mem":[0-9]*' | cut -d: -f2)
        if [ -n "$MEM" ]; then
            MEM_MB=$((MEM / 1024 / 1024))
            echo "  内存使用: ${MEM_MB} MB"
        fi
        
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        echo "  连接数: ${CONNECTIONS:-0}"
    fi
    
    # 检查进程
    NATS_PID=$(pgrep -f nats-server | head -1)
    if [ -n "$NATS_PID" ]; then
        CPU=$(ps -p $NATS_PID -o %cpu= 2>/dev/null)
        echo "  CPU使用: ${CPU}%"
    fi
}

check_rabbitmq_resources() {
    echo "RabbitMQ资源使用:"
    
    if docker ps | grep -q rabbitmq; then
        STATS=$(docker stats rabbitmq --no-stream --format "{{.MemUsage}}\t{{.CPUPerc}}" 2>/dev/null)
        if [ -n "$STATS" ]; then
            echo "  $STATS"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        MEM=$(rabbitmqctl status 2>/dev/null | grep -i memory | head -1)
        echo "  $MEM"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_resources
        ;;
    nats)
        check_nats_resources
        ;;
    rabbitmq)
        check_rabbitmq_resources
        ;;
    all)
        check_kafka_resources
        echo ""
        check_nats_resources
        echo ""
        check_rabbitmq_resources
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "资源使用检查完成！"
