#!/bin/bash
# 消息队列集群状态检查脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列集群状态 ==="

check_kafka_cluster() {
    echo "Kafka集群状态:"
    
    if command -v kafka-broker-api-versions.sh &> /dev/null; then
        # 检查Broker列表
        BROKERS=$(kafka-broker-api-versions.sh --bootstrap-server localhost:9092 \
            --command-config /dev/null 2>/dev/null | grep -c "id" || echo "0")
        echo "  Broker数量: $BROKERS"
        
        # 检查Topic和分区
        if command -v kafka-topics.sh &> /dev/null; then
            TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "  Topic数量: $TOPICS"
        fi
    else
        echo "  ⚠️  需要Kafka工具"
    fi
}

check_nats_cluster() {
    echo "NATS集群状态:"
    
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        ROUTES=$(curl -s http://localhost:8222/varz | grep -o '"routes":[0-9]*' | cut -d: -f2)
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        echo "  路由数: $ROUTES"
        echo "  连接数: $CONNECTIONS"
    else
        echo "  ❌ 无法连接到NATS监控端口"
    fi
}

check_rabbitmq_cluster() {
    echo "RabbitMQ集群状态:"
    
    if docker ps | grep -q rabbitmq; then
        docker exec rabbitmq rabbitmqctl cluster_status 2>/dev/null | head -10
    elif command -v rabbitmqctl &> /dev/null; then
        rabbitmqctl cluster_status 2>/dev/null | head -10
    else
        echo "  ❌ 未找到RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_cluster
        ;;
    nats)
        check_nats_cluster
        ;;
    rabbitmq)
        check_rabbitmq_cluster
        ;;
    all)
        check_kafka_cluster
        echo ""
        check_nats_cluster
        echo ""
        check_rabbitmq_cluster
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "集群状态检查完成！"
