#!/bin/bash
# 消息队列指标导出脚本

set -e

MQ_TYPE=${1:-"kafka"}
OUTPUT_FILE=${2:-"metrics_$(date +%Y%m%d_%H%M%S).json"}

echo "=== 消息队列指标导出 ==="

export_kafka_metrics() {
    echo "导出Kafka指标..."
    
    METRICS=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "system": "kafka",
  "topics": $(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l),
  "status": "running"
}
EOF
)
    
    echo "$METRICS" > "$OUTPUT_FILE"
    echo "  ✅ 指标已导出到: $OUTPUT_FILE"
}

export_nats_metrics() {
    echo "导出NATS指标..."
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        curl -s http://localhost:8222/varz > "$OUTPUT_FILE"
        echo "  ✅ 指标已导出到: $OUTPUT_FILE"
    else
        echo "  ❌ 无法连接到NATS监控端口"
        return 1
    fi
}

export_rabbitmq_metrics() {
    echo "导出RabbitMQ指标..."
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null > "$OUTPUT_FILE"
        echo "  ✅ 指标已导出到: $OUTPUT_FILE"
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl list_queues name messages 2>/dev/null > "$OUTPUT_FILE"
        echo "  ✅ 指标已导出到: $OUTPUT_FILE"
    else
        echo "  ❌ 未找到RabbitMQ"
        return 1
    fi
}

case $MQ_TYPE in
    kafka)
        export_kafka_metrics
        ;;
    nats)
        export_nats_metrics
        ;;
    rabbitmq)
        export_rabbitmq_metrics
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [output_file]"
        exit 1
        ;;
esac

echo "指标导出完成！"
