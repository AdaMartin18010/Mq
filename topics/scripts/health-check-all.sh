#!/bin/bash
# 所有消息队列系统健康检查脚本

set -e

echo "=== 消息队列系统健康检查 ==="
echo ""

check_kafka() {
    echo "检查Kafka..."
    if command -v kafka-topics.sh &> /dev/null; then
        if kafka-topics.sh --list --bootstrap-server localhost:9092 &> /dev/null; then
            echo "  ✅ Kafka运行正常"
        else
            echo "  ❌ Kafka连接失败"
        fi
    else
        echo "  ⚠️  Kafka工具未安装"
    fi
}

check_nats() {
    echo "检查NATS..."
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "  ✅ NATS运行正常"
    else
        echo "  ❌ NATS连接失败"
    fi
}

check_rabbitmq() {
    echo "检查RabbitMQ..."
    if docker ps | grep -q rabbitmq; then
        if docker exec rabbitmq rabbitmqctl status &> /dev/null; then
            echo "  ✅ RabbitMQ运行正常"
        else
            echo "  ❌ RabbitMQ状态异常"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        if rabbitmqctl status &> /dev/null; then
            echo "  ✅ RabbitMQ运行正常"
        else
            echo "  ❌ RabbitMQ状态异常"
        fi
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
}

check_redis() {
    echo "检查Redis..."
    if command -v redis-cli &> /dev/null; then
        if redis-cli ping &> /dev/null; then
            echo "  ✅ Redis运行正常"
        else
            echo "  ❌ Redis连接失败"
        fi
    else
        echo "  ⚠️  Redis未安装"
    fi
}

check_kafka
echo ""
check_nats
echo ""
check_rabbitmq
echo ""
check_redis
echo ""

echo "健康检查完成！"
