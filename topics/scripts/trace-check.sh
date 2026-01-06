#!/bin/bash
# 消息追踪配置检查脚本

set -e

echo "=== 消息追踪配置检查 ==="
echo ""

check_trace_config() {
    echo "检查追踪配置..."
    
    echo ""
    echo "--- 追踪工具检查 ---"
    
    # 检查Jaeger
    if command -v jaeger &> /dev/null || docker ps | grep -q jaeger; then
        echo "  ✅ Jaeger已安装"
    else
        echo "  ⚠️  Jaeger未安装"
    fi
    
    # 检查Zipkin
    if command -v zipkin &> /dev/null || docker ps | grep -q zipkin; then
        echo "  ✅ Zipkin已安装"
    else
        echo "  ⚠️  Zipkin未安装"
    fi
    
    # 检查Prometheus
    if command -v prometheus &> /dev/null || docker ps | grep -q prometheus; then
        echo "  ✅ Prometheus已安装"
    else
        echo "  ⚠️  Prometheus未安装"
    fi
    
    echo ""
    echo "--- 追踪配置建议 ---"
    echo "1. 统一追踪ID格式"
    echo "2. 配置采样率（建议1-10%）"
    echo "3. 设置追踪数据保留策略"
    echo "4. 配置追踪数据存储"
    echo "5. 集成监控告警"
    echo ""
    
    echo "--- 追踪指标建议 ---"
    echo "1. 消息发送速率"
    echo "2. 消息消费速率"
    echo "3. 消息延迟（P50/P95/P99）"
    echo "4. 端到端延迟"
    echo "5. 错误率"
}

check_trace_config

echo ""
echo "消息追踪配置检查完成！"
