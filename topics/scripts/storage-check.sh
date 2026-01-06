#!/bin/bash
# 消息存储配置检查脚本

set -e

echo "=== 消息存储配置检查 ==="
echo ""

check_kafka_storage() {
    echo "检查Kafka存储配置..."
    
    if command -v kafka-topics.sh &> /dev/null; then
        echo "  Kafka存储路径:"
        KAFKA_LOG_DIRS=$(grep "log.dirs" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | \
            cut -d'=' -f2 | tr ',' '\n' | head -3)
        if [ -n "$KAFKA_LOG_DIRS" ]; then
            echo "$KAFKA_LOG_DIRS" | while read dir; do
                if [ -d "$dir" ]; then
                    SIZE=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
                    echo "    - $dir: $SIZE"
                fi
            done
        else
            echo "    ⚠️  未找到log.dirs配置"
        fi
        
        echo ""
        echo "  Kafka保留策略:"
        RETENTION_HOURS=$(grep "log.retention.hours" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | \
            cut -d'=' -f2 | head -1)
        RETENTION_BYTES=$(grep "log.retention.bytes" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | \
            cut -d'=' -f2 | head -1)
        echo "    - 保留时间: ${RETENTION_HOURS:-未配置}小时"
        echo "    - 保留大小: ${RETENTION_BYTES:-未配置}字节"
    else
        echo "  ⚠️  Kafka未安装"
    fi
}

check_nats_storage() {
    echo "检查NATS存储配置..."
    
    if docker ps | grep -q nats; then
        echo "  NATS存储:"
        echo "    - NATS Core: 内存存储（无持久化）"
        echo "    - JetStream: 文件存储（持久化）"
    elif command -v nats-server &> /dev/null; then
        echo "  NATS存储:"
        echo "    - NATS Core: 内存存储（无持久化）"
        echo "    - JetStream: 文件存储（持久化）"
    else
        echo "  ⚠️  NATS未安装"
    fi
}

check_rabbitmq_storage() {
    echo "检查RabbitMQ存储配置..."
    
    if docker ps | grep -q rabbitmq; then
        echo "  RabbitMQ存储路径:"
        RABBITMQ_DATA_DIR="/var/lib/rabbitmq/mnesia"
        if docker exec rabbitmq test -d "$RABBITMQ_DATA_DIR" 2>/dev/null; then
            SIZE=$(docker exec rabbitmq du -sh "$RABBITMQ_DATA_DIR" 2>/dev/null | awk '{print $1}')
            echo "    - $RABBITMQ_DATA_DIR: $SIZE"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        RABBITMQ_DATA_DIR=$(rabbitmqctl environment 2>/dev/null | \
            grep "MNESIA_BASE" | awk '{print $2}' | tr -d '"')
        if [ -n "$RABBITMQ_DATA_DIR" ] && [ -d "$RABBITMQ_DATA_DIR" ]; then
            SIZE=$(du -sh "$RABBITMQ_DATA_DIR" 2>/dev/null | awk '{print $1}')
            echo "    - $RABBITMQ_DATA_DIR: $SIZE"
        fi
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
}

check_kafka_storage
echo ""
check_nats_storage
echo ""
check_rabbitmq_storage

echo ""
echo "--- 存储建议 ---"
echo "1. 合理配置保留策略（时间/大小/数量）"
echo "2. 定期清理过期数据"
echo "3. 配置数据压缩"
echo "4. 监控存储使用情况"
echo "5. 规划存储容量"
echo "6. 实施备份策略"
echo "7. 定期恢复演练"

echo ""
echo "消息存储配置检查完成！"
