#!/bin/bash
# 消息队列指标收集脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列指标 ==="

collect_kafka_metrics() {
    echo "Kafka指标:"
    
    if command -v kafka-run-class.sh &> /dev/null; then
        echo "  使用JMX收集指标:"
        echo "  jconsole localhost:9999"
        echo ""
        echo "  或使用kafka-consumer-groups.sh:"
        kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
            --list 2>/dev/null | head -5
    else
        echo "  ⚠️  需要Kafka工具"
    fi
}

collect_nats_metrics() {
    echo "NATS指标:"
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "  连接数: $(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)"
        echo "  入站消息: $(curl -s http://localhost:8222/varz | grep -o '"in_msgs":[0-9]*' | cut -d: -f2)"
        echo "  出站消息: $(curl -s http://localhost:8222/varz | grep -o '"out_msgs":[0-9]*' | cut -d: -f2)"
        echo "  内存使用: $(curl -s http://localhost:8222/varz | grep -o '"mem":[0-9]*' | cut -d: -f2) bytes"
    else
        echo "  ❌ 无法连接到NATS监控端口"
    fi
}

collect_rabbitmq_metrics() {
    echo "RabbitMQ指标:"
    
    if docker ps | grep -q rabbitmq; then
        echo "  队列数: $(docker exec rabbitmq rabbitmqctl list_queues 2>/dev/null | wc -l)"
        echo "  连接数: $(docker exec rabbitmq rabbitmqctl list_connections 2>/dev/null | wc -l)"
    elif command -v rabbitmqctl &> /dev/null; then
        echo "  队列数: $(rabbitmqctl list_queues 2>/dev/null | wc -l)"
        echo "  连接数: $(rabbitmqctl list_connections 2>/dev/null | wc -l)"
    else
        echo "  ❌ 未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        collect_kafka_metrics
        ;;
    nats)
        collect_nats_metrics
        ;;
    rabbitmq)
        collect_rabbitmq_metrics
        ;;
    all)
        collect_kafka_metrics
        echo ""
        collect_nats_metrics
        echo ""
        collect_rabbitmq_metrics
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "指标收集完成！"
