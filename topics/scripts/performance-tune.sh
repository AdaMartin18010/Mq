#!/bin/bash
# 消息性能调优脚本

set -e

echo "=== 消息性能调优 ==="
echo ""

check_producer_tuning() {
    echo "检查Producer性能调优..."
    echo ""
    echo "  --- Kafka Producer调优 ---"
    echo "  - batch.size: 建议32768-65536"
    echo "  - linger.ms: 建议10-100"
    echo "  - compression.type: 建议snappy/lz4"
    echo "  - acks: 建议1（平衡性能和可靠性）"
    echo "  - buffer.memory: 建议67108864"
    echo ""
    echo "  --- NATS Producer调优 ---"
    echo "  - 批量发布: 使用Flush()批量刷新"
    echo "  - 连接池: 复用连接"
    echo ""
    echo "  --- RabbitMQ Producer调优 ---"
    echo "  - 批量发布: 减少网络往返"
    echo "  - 持久化: 根据需求选择"
}

check_consumer_tuning() {
    echo ""
    echo "检查Consumer性能调优..."
    echo ""
    echo "  --- Kafka Consumer调优 ---"
    echo "  - fetch.min.bytes: 建议1024-4096"
    echo "  - fetch.max.wait.ms: 建议100-500"
    echo "  - max.partition.fetch.bytes: 建议1048576"
    echo "  - max.poll.records: 建议500-1000"
    echo ""
    echo "  --- NATS Consumer调优 ---"
    echo "  - SetPendingLimits: 设置待处理限制"
    echo "  - 并发处理: 使用goroutine"
    echo ""
    echo "  --- RabbitMQ Consumer调优 ---"
    echo "  - basic_qos prefetch_count: 建议100-500"
    echo "  - 并发消费: 使用多线程/进程"
}

check_system_tuning() {
    echo ""
    echo "检查系统性能调优..."
    echo ""
    echo "  --- 分区优化 ---"
    echo "  - 增加分区数: 提高并行度"
    echo "  - 分区策略: 根据业务选择"
    echo ""
    echo "  --- 网络优化 ---"
    echo "  - 网络延迟: 优化网络配置"
    echo "  - 带宽: 确保足够带宽"
    echo ""
    echo "  --- 资源优化 ---"
    echo "  - CPU: 多核利用"
    echo "  - 内存: 合理分配"
    echo "  - 磁盘I/O: SSD优化"
}

check_producer_tuning
check_consumer_tuning
check_system_tuning

echo ""
echo "--- 性能调优最佳实践 ---"
echo "1. 批量处理提高吞吐量"
echo "2. 压缩减少网络传输"
echo "3. 合理设置ACK策略"
echo "4. 优化分区和并发"
echo "5. 监控性能指标并持续优化"

echo ""
echo "消息性能调优完成！"
