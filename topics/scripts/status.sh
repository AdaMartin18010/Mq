#!/bin/bash
# 消息队列状态检查脚本
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列状态检查 ==="
echo ""

check_kafka() {
    echo "📊 Kafka状态:"
    if pgrep -f "kafka.Kafka" > /dev/null; then
        echo "  ✅ 运行中"
        if command -v kafka-topics.sh &> /dev/null; then
            TOPIC_COUNT=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "  📁 Topic数量: $TOPIC_COUNT"
        fi
    else
        echo "  ❌ 未运行"
    fi
}

check_nats() {
    echo "📊 NATS状态:"
    if pgrep -f "nats-server" > /dev/null; then
        echo "  ✅ 运行中"
        if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
            CONN=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
            echo "  🔗 连接数: $CONN"
        fi
    else
        echo "  ❌ 未运行"
    fi
}

check_rabbitmq() {
    echo "📊 RabbitMQ状态:"
    if $RT ps | grep -q rabbitmq || pgrep -f "beam.smp.*rabbit" > /dev/null; then
        echo "  ✅ 运行中"
        if $RT ps | grep -q rabbitmq; then
            echo "  🐳 Docker容器运行中"
        fi
    else
        echo "  ❌ 未运行"
    fi
}

check_redis() {
    echo "📊 Redis状态:"
    if pgrep -f "redis-server" > /dev/null; then
        echo "  ✅ 运行中"
        if command -v redis-cli &> /dev/null; then
            if redis-cli ping > /dev/null 2>&1; then
                echo "  ✅ 连接正常"
            fi
        fi
    else
        echo "  ❌ 未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka
        ;;
    nats)
        check_nats
        ;;
    rabbitmq)
        check_rabbitmq
        ;;
    redis)
        check_redis
        ;;
    all)
        check_kafka
        echo ""
        check_nats
        echo ""
        check_rabbitmq
        echo ""
        check_redis
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo ""
echo "状态检查完成！"
