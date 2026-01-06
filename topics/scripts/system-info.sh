#!/bin/bash
# 系统信息收集脚本

set -e

OUTPUT_FILE=${1:-"system_info_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 系统信息收集 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 系统信息报告 ==="
    echo "收集时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- 操作系统信息 ---"
    echo "操作系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "主机名: $(hostname)"
    echo "架构: $(uname -m)"
    echo ""
    
    echo "--- CPU信息 ---"
    if command -v lscpu &> /dev/null; then
        lscpu | grep -E "Model name|CPU\(s\)|Thread|Core" | head -5
    else
        echo "CPU核心数: $(nproc)"
    fi
    echo ""
    
    echo "--- 内存信息 ---"
    free -h
    echo ""
    
    echo "--- 磁盘信息 ---"
    df -h | head -10
    echo ""
    
    echo "--- 网络信息 ---"
    if command -v ip &> /dev/null; then
        ip addr show | grep -E "inet |inet6 " | head -5
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -E "inet " | head -5
    fi
    echo ""
    
    echo "--- 已安装软件 ---"
    echo "Java: $(java -version 2>&1 | head -1 || echo '未安装')"
    echo "Python: $(python3 --version 2>&1 || echo '未安装')"
    echo "Docker: $(docker --version 2>&1 || echo '未安装')"
    echo ""
    
    echo "--- 消息队列系统 ---"
    if command -v kafka-server-start.sh &> /dev/null; then
        echo "Kafka: ✅ 已安装"
    else
        echo "Kafka: ❌ 未安装"
    fi
    
    if command -v nats-server &> /dev/null; then
        echo "NATS: ✅ 已安装"
    else
        echo "NATS: ❌ 未安装"
    fi
    
    if command -v rabbitmqctl &> /dev/null || docker ps | grep -q rabbitmq; then
        echo "RabbitMQ: ✅ 已安装"
    else
        echo "RabbitMQ: ❌ 未安装"
    fi
    
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "系统信息收集完成！报告已保存到: $OUTPUT_FILE"
