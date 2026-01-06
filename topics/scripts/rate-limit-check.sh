#!/bin/bash
# 消息限流检查脚本

set -e

echo "=== 消息限流检查 ==="
echo ""

check_producer_rate_limit() {
    echo "检查Producer限流配置..."
    echo ""
    echo "  --- Kafka Producer限流 ---"
    echo "  - max.in.flight.requests.per.connection: 建议5"
    echo "  - batch.size: 建议16384-32768"
    echo "  - linger.ms: 建议10-100"
    echo "  - max.request.size: 建议1048576"
    echo ""
    echo "  --- NATS Producer限流 ---"
    echo "  - 应用层限流: 使用rate.Limiter"
    echo "  - 批量大小: 建议100-1000"
    echo ""
    echo "  --- RabbitMQ Producer限流 ---"
    echo "  - 应用层限流: 使用RateLimiter"
    echo "  - 批量大小: 建议100-1000"
}

check_consumer_rate_limit() {
    echo ""
    echo "检查Consumer限流配置..."
    echo ""
    echo "  --- Kafka Consumer限流 ---"
    echo "  - fetch.min.bytes: 建议1-1024"
    echo "  - fetch.max.wait.ms: 建议100-500"
    echo "  - max.partition.fetch.bytes: 建议1048576"
    echo "  - max.poll.records: 建议100-500"
    echo ""
    echo "  --- NATS Consumer限流 ---"
    echo "  - SetPendingLimits: 建议1000条或10MB"
    echo "  - 应用层限流: 使用rate.Limiter"
    echo ""
    echo "  --- RabbitMQ Consumer限流 ---"
    echo "  - basic_qos prefetch_count: 建议10-100"
    echo "  - 应用层限流: 使用RateLimiter"
}

check_rate_limit_strategies() {
    echo ""
    echo "检查限流策略..."
    echo ""
    echo "  --- 限流策略类型 ---"
    echo "  1. 固定窗口限流: 固定时间窗口，简单实现"
    echo "  2. 滑动窗口限流: 滑动时间窗口，平滑限流"
    echo "  3. 令牌桶限流: 令牌生成，支持突发流量"
    echo ""
    echo "  --- 限流粒度 ---"
    echo "  1. 全局限流: 整个系统限流"
    echo "  2. 分区限流: 按分区限流"
    echo "  3. 用户限流: 按用户限流"
    echo ""
    echo "  --- 限流处理 ---"
    echo "  1. 拒绝策略: 直接拒绝超限请求"
    echo "  2. 等待策略: 等待直到允许"
    echo "  3. 降级策略: 降级处理"
}

check_producer_rate_limit
check_consumer_rate_limit
check_rate_limit_strategies

echo ""
echo "--- 限流最佳实践 ---"
echo "1. 使用令牌桶限流策略（支持突发流量）"
echo "2. 合理设置限流阈值（根据系统容量）"
echo "3. 监控限流效果（限流率、拒绝率）"
echo "4. 实现多级限流（全局+分区+用户）"
echo "5. 限流告警和自动调整"

echo ""
echo "消息限流检查完成！"
