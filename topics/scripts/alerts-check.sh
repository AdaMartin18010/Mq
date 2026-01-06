#!/bin/bash
# 消息队列告警检查脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列告警检查 ==="

check_kafka_alerts() {
    echo "检查Kafka告警..."
    
    # 检查Broker状态
    if command -v kafka-broker-api-versions.sh &> /dev/null; then
        if kafka-broker-api-versions.sh --bootstrap-server localhost:9092 &> /dev/null; then
            echo "  ✅ Broker连接正常"
        else
            echo "  ⚠️  Broker连接异常"
        fi
    fi
    
    # 检查Topic数量
    if command -v kafka-topics.sh &> /dev/null; then
        TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
        if [ "$TOPICS" -gt 100 ]; then
            echo "  ⚠️  Topic数量过多: $TOPICS"
        else
            echo "  ✅ Topic数量正常: $TOPICS"
        fi
    fi
}

check_nats_alerts() {
    echo "检查NATS告警..."
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" -gt 50000 ]; then
            echo "  ⚠️  连接数过多: $CONNECTIONS"
        else
            echo "  ✅ 连接数正常: ${CONNECTIONS:-0}"
        fi
    else
        echo "  ❌ NATS监控端口不可用"
    fi
}

check_rabbitmq_alerts() {
    echo "检查RabbitMQ告警..."
    
    if docker ps | grep -q rabbitmq; then
        QUEUES=$(docker exec rabbitmq rabbitmqctl list_queues name messages 2>/dev/null | wc -l)
        if [ "$QUEUES" -gt 100 ]; then
            echo "  ⚠️  队列数量过多: $QUEUES"
        else
            echo "  ✅ 队列数量正常: $QUEUES"
        fi
    else
        echo "  ⚠️  RabbitMQ未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_alerts
        ;;
    nats)
        check_nats_alerts
        ;;
    rabbitmq)
        check_rabbitmq_alerts
        ;;
    all)
        check_kafka_alerts
        echo ""
        check_nats_alerts
        echo ""
        check_rabbitmq_alerts
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "告警检查完成！"
