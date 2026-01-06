#!/bin/bash
# 性能报告生成脚本

set -e

MQ_TYPE=${1:-"all"}
OUTPUT_FILE=${2:-"performance_report_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 生成性能报告 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统性能报告 ==="
    echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    if [ "$MQ_TYPE" = "kafka" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- Kafka性能指标 ---"
        if command -v kafka-topics.sh &> /dev/null; then
            TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "Topics数量: $TOPICS"
        fi
        echo ""
    fi
    
    if [ "$MQ_TYPE" = "nats" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- NATS性能指标 ---"
        if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
            curl -s http://localhost:8222/varz | \
                grep -E '"connections"|"in_msgs"|"out_msgs"|"in_bytes"|"out_bytes"|"mem"' | \
                sed 's/"//g' | sed 's/,//g'
        fi
        echo ""
    fi
    
    if [ "$MQ_TYPE" = "rabbitmq" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- RabbitMQ性能指标 ---"
        if docker ps | grep -q rabbitmq; then
            docker exec rabbitmq rabbitmqctl list_queues name messages messages_ready messages_unacknowledged 2>/dev/null | head -20
        fi
        echo ""
    fi
    
    echo "--- 系统资源使用 ---"
    echo "CPU使用率: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
    echo "内存使用: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "磁盘使用: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "性能报告已生成: $OUTPUT_FILE"
