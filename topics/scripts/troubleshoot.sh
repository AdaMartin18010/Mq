#!/bin/bash
# 故障排查脚本

set -e

MQ_TYPE=${1:-"all"}
ISSUE_TYPE=${2:-"all"}

echo "=== 消息队列故障排查 ==="
echo ""

troubleshoot_kafka() {
    echo "Kafka故障排查:"
    
    # 检查连接
    if command -v kafka-broker-api-versions.sh &> /dev/null; then
        if kafka-broker-api-versions.sh --bootstrap-server localhost:9092 &> /dev/null; then
            echo "  ✅ Broker连接正常"
        else
            echo "  ❌ Broker连接失败"
            echo "    检查: 1) Broker是否运行 2) 端口9092是否开放 3) 网络连接"
        fi
    fi
    
    # 检查Topic
    if command -v kafka-topics.sh &> /dev/null; then
        TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
        echo "  Topics数量: $TOPICS"
    fi
    
    # 检查日志
    if [ -d "kafka_*/logs" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        ERRORS=$(grep -i error "$KAFKA_DIR/logs/server.log" 2>/dev/null | tail -5 | wc -l)
        if [ "$ERRORS" -gt 0 ]; then
            echo "  ⚠️  发现错误日志，请检查: $KAFKA_DIR/logs/server.log"
        fi
    fi
}

troubleshoot_nats() {
    echo "NATS故障排查:"
    
    # 检查连接
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "  ✅ NATS连接正常"
    else
        echo "  ❌ NATS连接失败"
        echo "    检查: 1) NATS Server是否运行 2) 端口4222是否开放 3) 监控端口8222"
    fi
    
    # 检查连接数
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        echo "  连接数: ${CONNECTIONS:-0}"
    fi
}

troubleshoot_rabbitmq() {
    echo "RabbitMQ故障排查:"
    
    # 检查连接
    if docker ps | grep -q rabbitmq; then
        if docker exec rabbitmq rabbitmqctl status &> /dev/null; then
            echo "  ✅ RabbitMQ连接正常"
        else
            echo "  ❌ RabbitMQ状态异常"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        if rabbitmqctl status &> /dev/null; then
            echo "  ✅ RabbitMQ连接正常"
        else
            echo "  ❌ RabbitMQ状态异常"
        fi
    else
        echo "  ⚠️  未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        troubleshoot_kafka
        ;;
    nats)
        troubleshoot_nats
        ;;
    rabbitmq)
        troubleshoot_rabbitmq
        ;;
    all)
        troubleshoot_kafka
        echo ""
        troubleshoot_nats
        echo ""
        troubleshoot_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all] [issue_type]"
        exit 1
        ;;
esac

echo ""
echo "故障排查完成！"
