#!/bin/bash
# 消息幂等性配置检查脚本

set -e

echo "=== 消息幂等性配置检查 ==="
echo ""

check_idempotency_config() {
    echo "检查幂等性配置..."
    
    echo ""
    echo "--- Kafka幂等性 ---"
    if [ -f "kafka_*/config/producer.properties" ]; then
        if grep -q "enable.idempotence=true" kafka_*/config/producer.properties; then
            echo "  ✅ Producer幂等性已启用"
        else
            echo "  ⚠️  Producer幂等性未启用"
        fi
    else
        echo "  ⚠️  Producer配置文件未找到"
    fi
    
    echo ""
    echo "--- NATS幂等性 ---"
    echo "  NATS幂等性实现:"
    echo "    - 使用MsgId实现幂等性"
    echo "    - 应用层幂等性检查"
    echo "    - ⚠️  NATS Core无原生幂等性支持"
    
    echo ""
    echo "--- RabbitMQ幂等性 ---"
    echo "  RabbitMQ幂等性实现:"
    echo "    - 使用message_id实现幂等性"
    echo "    - 应用层幂等性检查"
    echo "    - ⚠️  RabbitMQ无原生幂等性支持"
    
    echo ""
    echo "--- 幂等性建议 ---"
    echo "1. 明确幂等性需求"
    echo "2. 选择合适的实现策略"
    echo "3. 实现消息ID唯一性"
    echo "4. 配置幂等性检查机制"
    echo "5. 测试幂等性保证"
}

check_idempotency_config

echo ""
echo "消息幂等性配置检查完成！"
