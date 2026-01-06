#!/bin/bash
# 消息延迟配置检查脚本

set -e

echo "=== 消息延迟配置检查 ==="
echo ""

check_delay_config() {
    echo "检查延迟消息配置..."
    
    echo ""
    echo "--- Kafka延迟消息 ---"
    echo "  Kafka延迟实现:"
    echo "    - 时间戳方案: 需应用层实现"
    echo "    - 延迟Topic方案: 需定时任务"
    echo "    - ⚠️  Kafka无原生延迟消息支持"
    
    echo ""
    echo "--- NATS延迟消息 ---"
    if command -v nats-server &> /dev/null; then
        echo "  ✅ NATS JetStream支持延迟消息"
        echo "    - 使用nats.Delay()参数"
        echo "    - 原生支持，性能好"
    else
        echo "  ⚠️  NATS未安装"
    fi
    
    echo ""
    echo "--- RabbitMQ延迟消息 ---"
    if docker ps | grep -q rabbitmq; then
        PLUGINS=$(docker exec rabbitmq rabbitmq-plugins list 2>/dev/null | grep -i delay || echo "")
        if echo "$PLUGINS" | grep -q "rabbitmq_delayed_message_exchange"; then
            echo "  ✅ 延迟插件已安装"
        else
            echo "  ⚠️  延迟插件未安装"
            echo "    需要安装: rabbitmq-delayed-message-exchange"
        fi
    elif command -v rabbitmqctl &> /dev/null; then
        PLUGINS=$(rabbitmq-plugins list 2>/dev/null | grep -i delay || echo "")
        if echo "$PLUGINS" | grep -q "rabbitmq_delayed_message_exchange"; then
            echo "  ✅ 延迟插件已安装"
        else
            echo "  ⚠️  延迟插件未安装"
        fi
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
    
    echo ""
    echo "--- 延迟消息建议 ---"
    echo "1. 明确延迟需求（固定/动态）"
    echo "2. 选择合适的实现方案"
    echo "3. 考虑延迟消息持久化"
    echo "4. 配置延迟消息监控"
    echo "5. 设置延迟消息告警"
}

check_delay_config

echo ""
echo "消息延迟配置检查完成！"
