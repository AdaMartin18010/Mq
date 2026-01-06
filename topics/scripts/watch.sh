#!/bin/bash
# 消息队列实时监控脚本（增强版）

set -e

MQ_TYPE=${1:-"kafka"}
INTERVAL=${2:-5}

echo "=== 消息队列实时监控 ==="
echo "按Ctrl+C退出"
echo ""

watch_kafka() {
    while true; do
        clear
        echo "=== Kafka实时监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if command -v kafka-topics.sh &> /dev/null; then
            TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "Topic数量: $TOPICS"
        fi
        
        if [ -d "kafka_*/logs" ]; then
            LOG_SIZE=$(du -sh kafka_*/logs 2>/dev/null | awk '{print $1}')
            echo "日志大小: $LOG_SIZE"
        fi
        
        sleep $INTERVAL
    done
}

watch_nats() {
    while true; do
        clear
        echo "=== NATS实时监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
            curl -s http://localhost:8222/varz | \
                grep -E '"connections"|"in_msgs"|"out_msgs"|"mem"' | \
                sed 's/"//g' | sed 's/,//g' | awk '{print "  " $0}'
        fi
        
        sleep $INTERVAL
    done
}

watch_rabbitmq() {
    while true; do
        clear
        echo "=== RabbitMQ实时监控 ==="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        if docker ps | grep -q rabbitmq; then
            docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | head -10
        fi
        
        sleep $INTERVAL
    done
}

case $MQ_TYPE in
    kafka)
        watch_kafka
        ;;
    nats)
        watch_nats
        ;;
    rabbitmq)
        watch_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [interval]"
        exit 1
        ;;
esac
