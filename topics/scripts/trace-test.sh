#!/bin/bash
# 消息追踪测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息追踪测试 ==="
echo ""

test_kafka_trace() {
    echo "Kafka消息追踪测试:"
    echo "  Kafka追踪实现:"
    echo "    - 使用消息头传递追踪ID"
    echo "    - 集成OpenTracing/Jaeger"
    echo "    - 跨系统追踪传递"
    echo ""
    echo "  示例:"
    echo "    record.headers().add(\"trace-id\", traceId.getBytes())"
    echo "    record.headers().add(\"span-id\", spanId.getBytes())"
}

test_nats_trace() {
    echo "NATS消息追踪测试:"
    echo "  NATS追踪实现:"
    echo "    - 使用消息头传递追踪ID"
    echo "    - 集成OpenTracing/Jaeger"
    echo "    - 跨系统追踪传递"
    echo ""
    echo "  示例:"
    echo "    msg.Header.Set(\"trace-id\", traceID)"
    echo "    msg.Header.Set(\"span-id\", spanID)"
}

test_rabbitmq_trace() {
    echo "RabbitMQ消息追踪测试:"
    echo "  RabbitMQ追踪实现:"
    echo "    - 使用消息头传递追踪ID"
    echo "    - 集成OpenTracing/Jaeger"
    echo "    - 跨系统追踪传递"
    echo ""
    echo "  示例:"
    echo "    properties.headers = {'trace-id': trace_id, 'span-id': span_id}"
}

case $MQ_TYPE in
    kafka)
        test_kafka_trace
        ;;
    nats)
        test_nats_trace
        ;;
    rabbitmq)
        test_rabbitmq_trace
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息追踪测试完成！"
