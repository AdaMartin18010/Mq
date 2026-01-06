#!/bin/bash
# 消息队列安全检查脚本

set -e

MQ_TYPE=${1:-"all"}

echo "=== 消息队列安全检查 ==="

check_kafka_security() {
    echo "Kafka安全检查:"
    
    if [ -f "kafka_*/config/server.properties" ]; then
        CONFIG="kafka_*/config/server.properties"
        
        # 检查SASL配置
        if grep -q "sasl.enabled.mechanisms" "$CONFIG"; then
            echo "  ✅ SASL认证已启用"
        else
            echo "  ⚠️  SASL认证未启用（生产环境建议启用）"
        fi
        
        # 检查SSL配置
        if grep -q "ssl.keystore.location" "$CONFIG"; then
            echo "  ✅ SSL加密已启用"
        else
            echo "  ⚠️  SSL加密未启用（生产环境建议启用）"
        fi
        
        # 检查ACL配置
        if grep -q "authorizer.class.name" "$CONFIG"; then
            echo "  ✅ ACL授权已配置"
        else
            echo "  ⚠️  ACL授权未配置（生产环境建议配置）"
        fi
    else
        echo "  ❌ 未找到Kafka配置文件"
    fi
}

check_nats_security() {
    echo "NATS安全检查:"
    
    if [ -f "nats-server.conf" ]; then
        CONFIG="nats-server.conf"
        
        # 检查TLS配置
        if grep -q "tls {" "$CONFIG"; then
            echo "  ✅ TLS加密已启用"
        else
            echo "  ⚠️  TLS加密未启用（生产环境建议启用）"
        fi
        
        # 检查认证配置
        if grep -q "authorization" "$CONFIG"; then
            echo "  ✅ 认证已配置"
        else
            echo "  ⚠️  认证未配置（生产环境建议配置）"
        fi
    else
        echo "  ⚠️  使用默认配置（建议配置TLS和认证）"
    fi
}

check_rabbitmq_security() {
    echo "RabbitMQ安全检查:"
    
    if docker ps | grep -q rabbitmq; then
        # 检查TLS配置
        if docker exec rabbitmq rabbitmqctl environment | grep -q "ssl"; then
            echo "  ✅ TLS加密已启用"
        else
            echo "  ⚠️  TLS加密未启用（生产环境建议启用）"
        fi
        
        # 检查用户配置
        USERS=$(docker exec rabbitmq rabbitmqctl list_users 2>/dev/null | wc -l)
        if [ "$USERS" -gt 1 ]; then
            echo "  ✅ 已配置用户（$USERS个）"
        else
            echo "  ⚠️  仅使用默认用户（生产环境建议创建专用用户）"
        fi
    else
        echo "  ⚠️  RabbitMQ未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        check_kafka_security
        ;;
    nats)
        check_nats_security
        ;;
    rabbitmq)
        check_rabbitmq_security
        ;;
    all)
        check_kafka_security
        echo ""
        check_nats_security
        echo ""
        check_rabbitmq_security
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all]"
        exit 1
        ;;
esac

echo ""
echo "安全检查完成！"
