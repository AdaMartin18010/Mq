#!/bin/bash
# 消息队列故障诊断脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息队列故障诊断 ==="

diagnose_kafka() {
    echo "诊断Kafka..."
    
    # 检查进程
    echo "1. 检查进程状态:"
    if pgrep -f "kafka.Kafka" > /dev/null; then
        echo "   ✅ Kafka进程运行中"
        ps aux | grep -E "kafka.Kafka|kafka-server" | grep -v grep | head -1
    else
        echo "   ❌ Kafka进程未运行"
    fi
    
    # 检查端口
    echo ""
    echo "2. 检查端口:"
    if nc -z localhost 9092 2>/dev/null; then
        echo "   ✅ 端口9092可访问"
    else
        echo "   ❌ 端口9092不可访问"
    fi
    
    # 检查日志
    echo ""
    echo "3. 检查最近错误日志:"
    if [ -d "kafka_*/logs" ]; then
        find kafka_*/logs -name "server.log" -type f -exec tail -20 {} \; 2>/dev/null | grep -i error | tail -5 || echo "   无错误日志"
    fi
    
    # 检查磁盘空间
    echo ""
    echo "4. 检查磁盘空间:"
    df -h . | tail -1
}

diagnose_nats() {
    echo "诊断NATS..."
    
    # 检查进程
    echo "1. 检查进程状态:"
    if pgrep -f "nats-server" > /dev/null; then
        echo "   ✅ NATS进程运行中"
        ps aux | grep nats-server | grep -v grep | head -1
    else
        echo "   ❌ NATS进程未运行"
    fi
    
    # 检查监控端口
    echo ""
    echo "2. 检查监控端口:"
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "   ✅ 监控端口8222可访问"
        echo "   连接数: $(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)"
    else
        echo "   ❌ 监控端口8222不可访问"
    fi
}

diagnose_rabbitmq() {
    echo "诊断RabbitMQ..."
    
    # 检查进程
    echo "1. 检查进程状态:"
    if docker ps | grep -q rabbitmq; then
        echo "   ✅ RabbitMQ容器运行中"
        docker ps | grep rabbitmq
    elif pgrep -f "beam.smp.*rabbit" > /dev/null; then
        echo "   ✅ RabbitMQ进程运行中"
    else
        echo "   ❌ RabbitMQ未运行"
    fi
    
    # 检查管理端口
    echo ""
    echo "2. 检查管理端口:"
    if curl -s -u guest:guest http://localhost:15672/api/overview > /dev/null 2>&1; then
        echo "   ✅ 管理端口15672可访问"
    else
        echo "   ❌ 管理端口15672不可访问"
    fi
}

case $MQ_TYPE in
    kafka)
        diagnose_kafka
        ;;
    nats)
        diagnose_nats
        ;;
    rabbitmq)
        diagnose_rabbitmq
        ;;
    all)
        diagnose_kafka
        echo ""
        diagnose_nats
        echo ""
        diagnose_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "诊断完成！"
