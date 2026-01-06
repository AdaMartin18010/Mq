#!/bin/bash
# 消息队列连接测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列连接测试 ==="

test_kafka() {
    echo "测试Kafka连接..."
    
    if nc -z localhost 9092 2>/dev/null; then
        echo "  ✅ 端口9092可访问"
        
        if command -v kafka-broker-api-versions.sh &> /dev/null; then
            kafka-broker-api-versions.sh --bootstrap-server localhost:9092 \
                --command-config /dev/null 2>/dev/null | head -3
            echo "  ✅ Kafka连接正常"
        else
            echo "  ⚠️  无法验证连接（需要Kafka工具）"
        fi
    else
        echo "  ❌ 端口9092不可访问"
        return 1
    fi
}

test_nats() {
    echo "测试NATS连接..."
    
    if nc -z localhost 4222 2>/dev/null; then
        echo "  ✅ 端口4222可访问"
        
        if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
            echo "  ✅ NATS连接正常"
            curl -s http://localhost:8222/varz | grep -E '"server_id"|"version"' | head -2
        else
            echo "  ⚠️  监控端口不可访问"
        fi
    else
        echo "  ❌ 端口4222不可访问"
        return 1
    fi
}

test_rabbitmq() {
    echo "测试RabbitMQ连接..."
    
    if nc -z localhost 5672 2>/dev/null; then
        echo "  ✅ 端口5672可访问"
        
        if curl -s -u guest:guest http://localhost:15672/api/overview > /dev/null 2>&1; then
            echo "  ✅ RabbitMQ连接正常"
        else
            echo "  ⚠️  管理端口不可访问"
        fi
    else
        echo "  ❌ 端口5672不可访问"
        return 1
    fi
}

test_redis() {
    echo "测试Redis连接..."
    
    if nc -z localhost 6379 2>/dev/null; then
        echo "  ✅ 端口6379可访问"
        
        if command -v redis-cli &> /dev/null; then
            if redis-cli ping > /dev/null 2>&1; then
                echo "  ✅ Redis连接正常"
                redis-cli info server | grep -E "redis_version|uptime" | head -2
            else
                echo "  ❌ Redis未响应"
                return 1
            fi
        else
            echo "  ⚠️  无法验证连接（需要redis-cli）"
        fi
    else
        echo "  ❌ 端口6379不可访问"
        return 1
    fi
}

case $MQ_TYPE in
    kafka)
        test_kafka
        ;;
    nats)
        test_nats
        ;;
    rabbitmq)
        test_rabbitmq
        ;;
    redis)
        test_redis
        ;;
    all)
        test_kafka && echo ""
        test_nats && echo ""
        test_rabbitmq && echo ""
        test_redis
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|redis|all]"
        exit 1
        ;;
esac

echo ""
echo "连接测试完成！"
