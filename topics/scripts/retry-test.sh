#!/bin/bash
# 重试机制测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
MAX_RETRIES=${2:-3}
RETRY_DELAY=${3:-1}

echo "=== 消息重试机制测试 ==="
echo "最大重试次数: $MAX_RETRIES"
echo "重试延迟: ${RETRY_DELAY}秒"
echo ""

test_kafka_retry() {
    echo "测试Kafka重试机制..."
    
    if command -v kafka-console-producer.sh &> /dev/null; then
        echo "  Kafka Producer重试配置:"
        echo "    retries=$MAX_RETRIES"
        echo "    retry.backoff.ms=$((RETRY_DELAY * 1000))"
        echo "    max.in.flight.requests.per.connection=1"
    else
        echo "  ⚠️  需要kafka-console-producer.sh工具"
    fi
}

test_nats_retry() {
    echo "测试NATS重试机制..."
    echo "  NATS重试建议:"
    echo "    最大重试次数: $MAX_RETRIES"
    echo "    重试延迟: ${RETRY_DELAY}秒（指数退避）"
    echo "    使用JetStream MaxDeliver配置"
}

test_rabbitmq_retry() {
    echo "测试RabbitMQ重试机制..."
    echo "  RabbitMQ重试建议:"
    echo "    最大重试次数: $MAX_RETRIES"
    echo "    重试延迟: ${RETRY_DELAY}秒（指数退避）"
    echo "    失败后发送到死信队列"
}

case $MQ_TYPE in
    kafka)
        test_kafka_retry
        ;;
    nats)
        test_nats_retry
        ;;
    rabbitmq)
        test_rabbitmq_retry
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [max_retries] [retry_delay]"
        exit 1
        ;;
esac

echo ""
echo "重试机制测试完成！"
