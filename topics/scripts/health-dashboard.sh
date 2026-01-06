#!/bin/bash
# 健康仪表板脚本（实时显示所有系统状态）

set -e

INTERVAL=${1:-5}

echo "=== 消息队列健康仪表板 ==="
echo "刷新间隔: ${INTERVAL}秒"
echo "按Ctrl+C退出"
echo ""

while true; do
    clear
    echo "=== 消息队列系统健康仪表板 ==="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- Kafka ---"
    if command -v kafka-broker-api-versions.sh &> /dev/null; then
        if kafka-broker-api-versions.sh --bootstrap-server localhost:9092 &> /dev/null; then
            echo "  状态: ✅ 运行中"
            TOPICS=$(kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | wc -l)
            echo "  Topics: $TOPICS"
        else
            echo "  状态: ❌ 连接失败"
        fi
    else
        echo "  状态: ⚠️  未安装"
    fi
    
    echo ""
    echo "--- NATS ---"
    if curl -s http://localhost:8222/varz > /dev/null 2>&1; then
        echo "  状态: ✅ 运行中"
        CONNECTIONS=$(curl -s http://localhost:8222/varz | grep -o '"connections":[0-9]*' | cut -d: -f2)
        echo "  连接数: ${CONNECTIONS:-0}"
    else
        echo "  状态: ❌ 连接失败"
    fi
    
    echo ""
    echo "--- RabbitMQ ---"
    if docker ps | grep -q rabbitmq; then
        if docker exec rabbitmq rabbitmqctl status &> /dev/null; then
            echo "  状态: ✅ 运行中"
            QUEUES=$(docker exec rabbitmq rabbitmqctl list_queues name 2>/dev/null | wc -l)
            echo "  队列数: $QUEUES"
        else
            echo "  状态: ❌ 状态异常"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        if rabbitmqctl status &> /dev/null; then
            echo "  状态: ✅ 运行中"
        else
            echo "  状态: ❌ 状态异常"
        fi
    else
        echo "  状态: ⚠️  未安装"
    fi
    
    echo ""
    echo "--- 系统资源 ---"
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    MEM=$(free -h | grep Mem | awk '{print $3 "/" $2}')
    DISK=$(df -h / | tail -1 | awk '{print $5}')
    echo "  CPU: ${CPU}%"
    echo "  内存: $MEM"
    echo "  磁盘: $DISK"
    
    sleep $INTERVAL
done
