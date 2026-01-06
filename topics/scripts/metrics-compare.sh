#!/bin/bash
# 消息队列指标对比脚本

set -e

OUTPUT_FILE=${1:-"metrics_compare_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息队列指标对比 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统指标对比 ==="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- Kafka ---"
    if command -v kafka-topics.sh &> /dev/null; then
        TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
        echo "Topics数量: $TOPICS"
    fi
    echo ""
    
    echo "--- NATS ---"
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        curl -s http://localhost:8222/varz | \
            grep -E '"connections"|"in_msgs"|"out_msgs"|"mem"' | \
            sed 's/"//g' | sed 's/,//g'
    fi
    echo ""
    
    echo "--- RabbitMQ ---"
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | head -10
    fi
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "指标对比完成！结果已保存到: $OUTPUT_FILE"
