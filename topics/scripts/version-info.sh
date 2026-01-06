#!/bin/bash
# 版本信息收集脚本

set -e

OUTPUT_FILE=${1:-"version_info_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 版本信息收集 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统版本信息 ==="
    echo "收集时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- Kafka版本 ---"
    if command -v kafka-server-start.sh &> /dev/null; then
        KAFKA_VERSION=$(kafka-server-start.sh --version 2>&1 | head -1 || echo "未知")
        echo "  Kafka: $KAFKA_VERSION"
    else
        echo "  Kafka: 未安装"
    fi
    
    echo ""
    echo "--- NATS版本 ---"
    if command -v nats-server &> /dev/null; then
        NATS_VERSION=$(nats-server --version 2>&1 | head -1 || echo "未知")
        echo "  NATS: $NATS_VERSION"
    else
        echo "  NATS: 未安装"
    fi
    
    echo ""
    echo "--- RabbitMQ版本 ---"
    if command -v rabbitmqctl &> /dev/null; then
        RABBITMQ_VERSION=$(rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  RabbitMQ: $RABBITMQ_VERSION"
    elif docker ps | grep -q rabbitmq; then
        RABBITMQ_VERSION=$(docker exec rabbitmq rabbitmqctl version 2>/dev/null | head -1 || echo "未知")
        echo "  RabbitMQ (Docker): $RABBITMQ_VERSION"
    else
        echo "  RabbitMQ: 未安装"
    fi
    
    echo ""
    echo "--- 系统版本 ---"
    echo "  操作系统: $(uname -s) $(uname -r)"
    echo "  Java: $(java -version 2>&1 | head -1 || echo '未安装')"
    echo "  Python: $(python3 --version 2>&1 || echo '未安装')"
    echo "  Docker: $(docker --version 2>&1 || echo '未安装')"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "版本信息收集完成！报告已保存到: $OUTPUT_FILE"
