#!/bin/bash
# 消息队列诊断脚本（综合诊断）

set -e

MQ_TYPE=${1:-"all"}
OUTPUT_FILE=${2:-"diagnostics_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息队列系统诊断 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统诊断报告 ==="
    echo "诊断时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- 系统信息 ---"
    echo "操作系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "主机名: $(hostname)"
    echo ""
    
    echo "--- 资源使用 ---"
    echo "CPU使用率: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
    echo "内存使用: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "磁盘使用: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
    echo ""
    
    if [ "$MQ_TYPE" = "kafka" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- Kafka诊断 ---"
        ./scripts/health-check.sh kafka 2>/dev/null || echo "  ⚠️  健康检查失败"
        ./scripts/version.sh kafka 2>/dev/null || echo "  ⚠️  版本检查失败"
        echo ""
    fi
    
    if [ "$MQ_TYPE" = "nats" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- NATS诊断 ---"
        ./scripts/health-check.sh nats 2>/dev/null || echo "  ⚠️  健康检查失败"
        ./scripts/version.sh nats 2>/dev/null || echo "  ⚠️  版本检查失败"
        echo ""
    fi
    
    if [ "$MQ_TYPE" = "rabbitmq" ] || [ "$MQ_TYPE" = "all" ]; then
        echo "--- RabbitMQ诊断 ---"
        ./scripts/health-check.sh rabbitmq 2>/dev/null || echo "  ⚠️  健康检查失败"
        ./scripts/version.sh rabbitmq 2>/dev/null || echo "  ⚠️  版本检查失败"
        echo ""
    fi
    
    echo "--- 网络连接 ---"
    netstat -tuln | grep -E "9092|4222|5672|6379" || echo "  未检测到消息队列端口"
    echo ""
    
    echo "--- 进程信息 ---"
    ps aux | grep -E "kafka|nats|rabbitmq|redis" | grep -v grep || echo "  未检测到消息队列进程"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "诊断完成！报告已保存到: $OUTPUT_FILE"
