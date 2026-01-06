#!/bin/bash
# 消息队列实时监控脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列实时监控 ==="
echo "按Ctrl+C退出"
echo ""

monitor_kafka() {
    while true; do
        clear
        echo "=== Kafka监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if command -v kafka-topics.sh &> /dev/null; then
            echo "Topic数量: $(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)"
        fi
        
        if [ -d "kafka_*/logs" ]; then
            echo "日志大小: $(du -sh kafka_*/logs 2>/dev/null | awk '{print $1}')"
        fi
        
        sleep 5
    done
}

monitor_nats() {
    while true; do
        clear
        echo "=== NATS监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
            curl -s http://localhost:8222/varz | grep -E '"connections"|"in_msgs"|"out_msgs"|"mem"' | \
                sed 's/"//g' | sed 's/,//g' | awk '{print "  " $0}'
        fi
        
        sleep 5
    done
}

monitor_rabbitmq() {
    while true; do
        clear
        echo "=== RabbitMQ监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if docker ps | grep -q rabbitmq; then
            docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | head -10
        fi
        
        sleep 5
    done
}

case $MQ_TYPE in
    kafka)
        monitor_kafka
        ;;
    nats)
        monitor_nats
        ;;
    rabbitmq)
        monitor_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac
