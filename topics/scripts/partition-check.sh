#!/bin/bash
# 消息分区配置检查脚本

set -e

echo "=== 消息分区配置检查 ==="
echo ""

check_partition_config() {
    echo "检查分区配置..."
    
    echo ""
    echo "--- Kafka分区 ---"
    if command -v kafka-topics.sh &> /dev/null; then
        echo "  Kafka Topics分区信息:"
        kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | \
            head -5 | \
            while read topic; do
                PARTITIONS=$(kafka-topics.sh --describe --bootstrap-server localhost:9092 --topic "$topic" 2>/dev/null | \
                    grep "PartitionCount" | awk '{print $2}' || echo "未知")
                echo "    - $topic: $PARTITIONS个分区"
            done
    else
        echo "  ⚠️  kafka-topics.sh未安装"
    fi
    
    echo ""
    echo "--- NATS分区 ---"
    echo "  NATS分区实现:"
    echo "    - 使用Subject前缀实现分区"
    echo "    - JetStream使用Stream"
    echo "    - ⚠️  NATS Core无原生分区支持"
    
    echo ""
    echo "--- RabbitMQ分区 ---"
    if docker ps | grep -q rabbitmq; then
        QUEUES=$(docker exec rabbitmq rabbitmqctl list_queues name 2>/dev/null | \
            grep -E "partition|part-" | wc -l)
        echo "  分区队列数量: $QUEUES"
    elif command -v rabbitmqctl &> /dev/null; then
        QUEUES=$(rabbitmqctl list_queues name 2>/dev/null | \
            grep -E "partition|part-" | wc -l)
        echo "  分区队列数量: $QUEUES"
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
    
    echo ""
    echo "--- 分区建议 ---"
    echo "1. 合理分区数量（根据吞吐量和消费者数量）"
    echo "2. 选择合适的分区键（保证顺序和负载均衡）"
    echo "3. 监控分区负载均衡"
    echo "4. 定期评估分区数量"
    echo "5. 规划分区扩容策略"
}

check_partition_config

echo ""
echo "消息分区配置检查完成！"
