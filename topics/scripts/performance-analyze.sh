#!/bin/bash
# 消息队列性能分析脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列性能分析 ==="

analyze_kafka() {
    echo "分析Kafka性能..."
    
    if ! command -v kafka-run-class.sh &> /dev/null; then
        echo "❌ 未找到Kafka工具"
        return 1
    fi
    
    echo "1. Topic统计:"
    kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l | xargs echo "   Topic数量:"
    
    echo ""
    echo "2. Consumer Lag (需要JMX):"
    echo "   使用 kafka-consumer-groups.sh 查看"
    
    echo ""
    echo "3. 磁盘使用:"
    if [ -d "kafka_*/logs" ]; then
        du -sh kafka_*/logs 2>/dev/null | head -1 | awk '{print "   日志大小: " $1}'
    fi
}

analyze_nats() {
    echo "分析NATS性能..."
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "1. 连接统计:"
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        IN_MSGS=$(curl -s http://localhost:8222/varz | grep -o '"in_msgs":[0-9]*' | cut -d: -f2)
        OUT_MSGS=$(curl -s http://localhost:8222/varz | grep -o '"out_msgs":[0-9]*' | cut -d: -f2)
        echo "   连接数: $CONNECTIONS"
        echo "   入站消息: $IN_MSGS"
        echo "   出站消息: $OUT_MSGS"
        
        echo ""
        echo "2. 内存使用:"
        MEM=$(curl -s http://localhost:8222/varz | grep -o '"mem":[0-9]*' | cut -d: -f2)
        if [ -n "$MEM" ]; then
            MEM_MB=$((MEM / 1024 / 1024))
            echo "   内存: ${MEM_MB}MB"
        fi
    else
        echo "❌ NATS监控端口不可达"
        return 1
    fi
}

analyze_rabbitmq() {
    echo "分析RabbitMQ性能..."
    
    if docker ps | grep -q rabbitmq; then
        echo "1. 队列统计:"
        docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | head -10
        
        echo ""
        echo "2. 连接统计:"
        docker exec rabbitmq rabbitmqctl list_connections 2>/dev/null | head -5
    elif command -v rabbitmqctl &> /dev/null; then
        echo "1. 队列统计:"
        rabbitmqctl list_queues name messages 2>/dev/null | head -10
    else
        echo "❌ 未找到RabbitMQ"
        return 1
    fi
}

case $MQ_TYPE in
    kafka)
        analyze_kafka
        ;;
    nats)
        analyze_nats
        ;;
    rabbitmq)
        analyze_rabbitmq
        ;;
    all)
        analyze_kafka
        echo ""
        analyze_nats
        echo ""
        analyze_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "性能分析完成！"
