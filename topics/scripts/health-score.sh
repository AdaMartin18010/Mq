#!/bin/bash
# 健康评分脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列健康评分 ==="
echo ""

score_kafka() {
    SCORE=100
    
    # 检查连接
    if ! command -v kafka-broker-api-versions.sh &> /dev/null; then
        SCORE=$((SCORE - 20))
    elif ! kafka-broker-api-versions.sh --bootstrap-server localhost:9092 &> /dev/null; then
        SCORE=$((SCORE - 20))
    fi
    
    # 检查Topic
    if command -v kafka-topics.sh &> /dev/null; then
        TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
        if [ "$TOPICS" -eq 0 ]; then
            SCORE=$((SCORE - 10))
        fi
    fi
    
    # 检查磁盘
    if [ -d "kafka_*/logs" ]; then
        DISK_USAGE=$(df -h kafka_*/logs 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
        if [ -n "$DISK_USAGE" ] && [ "$DISK_USAGE" -gt 90 ]; then
            SCORE=$((SCORE - 15))
        elif [ -n "$DISK_USAGE" ] && [ "$DISK_USAGE" -gt 80 ]; then
            SCORE=$((SCORE - 10))
        fi
    fi
    
    echo "Kafka健康评分: $SCORE/100"
    
    if [ "$SCORE" -ge 90 ]; then
        echo "  状态: ✅ 优秀"
    elif [ "$SCORE" -ge 70 ]; then
        echo "  状态: ⚠️  良好"
    else
        echo "  状态: ❌ 需要关注"
    fi
}

score_nats() {
    SCORE=100
    
    # 检查连接
    if ! curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        SCORE=$((SCORE - 30))
    else
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" -gt 50000 ]; then
            SCORE=$((SCORE - 10))
        fi
    fi
    
    echo "NATS健康评分: $SCORE/100"
    
    if [ "$SCORE" -ge 90 ]; then
        echo "  状态: ✅ 优秀"
    elif [ "$SCORE" -ge 70 ]; then
        echo "  状态: ⚠️  良好"
    else
        echo "  状态: ❌ 需要关注"
    fi
}

score_rabbitmq() {
    SCORE=100
    
    # 检查连接
    if docker ps | grep -q rabbitmq; then
        if ! docker exec rabbitmq rabbitmqctl status &> /dev/null; then
            SCORE=$((SCORE - 30))
        fi
    elif ! command -v rabbitmqctl &> /dev/null; then
        SCORE=$((SCORE - 30))
    elif ! rabbitmqctl status &> /dev/null; then
        SCORE=$((SCORE - 30))
    fi
    
    echo "RabbitMQ健康评分: $SCORE/100"
    
    if [ "$SCORE" -ge 90 ]; then
        echo "  状态: ✅ 优秀"
    elif [ "$SCORE" -ge 70 ]; then
        echo "  状态: ⚠️  良好"
    else
        echo "  状态: ❌ 需要关注"
    fi
}

case $MQ_TYPE in
    kafka)
        score_kafka
        ;;
    nats)
        score_nats
        ;;
    rabbitmq)
        score_rabbitmq
        ;;
    all)
        score_kafka
        echo ""
        score_nats
        echo ""
        score_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "健康评分完成！"
