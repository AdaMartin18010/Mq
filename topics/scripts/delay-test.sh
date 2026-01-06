#!/bin/bash
# 消息延迟测试脚本

set -e

MQ_TYPE=${1:-"rabbitmq"}

echo "=== 消息延迟测试 ==="
echo ""

test_kafka_delay() {
    echo "Kafka延迟消息测试:"
    echo "  Kafka延迟实现:"
    echo "    - 使用时间戳实现延迟"
    echo "    - 延迟Topic方案"
    echo "    - 应用层延迟处理"
    echo ""
    echo "  示例:"
    echo "    long delayTime = System.currentTimeMillis() + 60000;"
    echo "    ProducerRecord<>(topic, null, delayTime, key, value)"
}

test_nats_delay() {
    echo "NATS延迟消息测试:"
    echo "  NATS延迟实现:"
    echo "    - JetStream延迟消息（原生支持）"
    echo "    - 应用层延迟处理"
    echo ""
    echo "  示例:"
    echo "    js.Publish(\"orders\", data, nats.Delay(60*time.Second))"
}

test_rabbitmq_delay() {
    echo "RabbitMQ延迟消息测试:"
    echo "  RabbitMQ延迟实现:"
    echo "    - 延迟插件（x-delayed-message-exchange）"
    echo "    - 原生支持延迟消息"
    echo ""
    echo "  示例:"
    echo "    properties.headers = {'x-delay': 60000}"
    echo ""
    echo "  ⚠️  需要安装rabbitmq-delayed-message-exchange插件"
}

case $MQ_TYPE in
    kafka)
        test_kafka_delay
        ;;
    nats)
        test_nats_delay
        ;;
    rabbitmq)
        test_rabbitmq_delay
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息延迟测试完成！"
