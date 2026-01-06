#!/bin/bash
# 消息队列安全审计脚本

set -e

MQ_TYPE=${1:-"all"}
OUTPUT_FILE=${2:-"security_audit_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息队列安全审计 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统安全审计报告 ==="
    echo "审计时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    audit_kafka() {
        echo "--- Kafka安全审计 ---"
        
        if [ -f "kafka_*/config/server.properties" ]; then
            CONFIG="kafka_*/config/server.properties"
            
            # 检查SASL配置
            if grep -q "sasl.enabled.mechanisms" "$CONFIG"; then
                echo "✅ SASL认证已启用"
            else
                echo "❌ SASL认证未启用"
            fi
            
            # 检查SSL配置
            if grep -q "ssl.keystore.location" "$CONFIG"; then
                echo "✅ SSL加密已启用"
            else
                echo "❌ SSL加密未启用"
            fi
            
            # 检查ACL配置
            if grep -q "authorizer.class.name" "$CONFIG"; then
                echo "✅ ACL授权已配置"
            else
                echo "❌ ACL授权未配置"
            fi
        else
            echo "⚠️  未找到Kafka配置文件"
        fi
        echo ""
    }
    
    audit_nats() {
        echo "--- NATS安全审计 ---"
        
        if [ -f "nats-server.conf" ]; then
            CONFIG="nats-server.conf"
            
            # 检查TLS配置
            if grep -q "tls {" "$CONFIG"; then
                echo "✅ TLS加密已启用"
            else
                echo "❌ TLS加密未启用"
            fi
            
            # 检查认证配置
            if grep -q "authorization" "$CONFIG"; then
                echo "✅ 认证已配置"
            else
                echo "❌ 认证未配置"
            fi
        else
            echo "⚠️  使用默认配置（建议配置TLS和认证）"
        fi
        echo ""
    }
    
    audit_rabbitmq() {
        echo "--- RabbitMQ安全审计 ---"
        
        if docker ps | grep -q rabbitmq; then
            # 检查用户配置
            USERS=$(docker exec rabbitmq rabbitmqctl list_users 2>/dev/null | wc -l)
            if [ "$USERS" -gt 1 ]; then
                echo "✅ 已配置用户（$USERS个）"
            else
                echo "❌ 仅使用默认用户"
            fi
            
            # 检查TLS配置
            if docker exec rabbitmq rabbitmqctl environment | grep -q "ssl"; then
                echo "✅ TLS加密已启用"
            else
                echo "❌ TLS加密未启用"
            fi
        else
            echo "⚠️  RabbitMQ未运行"
        fi
        echo ""
    }
    
    case $MQ_TYPE in
        kafka)
            audit_kafka
            ;;
        nats)
            audit_nats
            ;;
        rabbitmq)
            audit_rabbitmq
            ;;
        all)
            audit_kafka
            audit_nats
            audit_rabbitmq
            ;;
        *)
            echo "用法: $0 [kafka|nats|rabbitmq|all] [output_file]"
            exit 1
            ;;
    esac
    
    echo "--- 安全建议 ---"
    echo "1. 启用TLS/SSL加密"
    echo "2. 配置认证和授权"
    echo "3. 定期更新密码和证书"
    echo "4. 监控异常访问"
    echo "5. 定期安全审计"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "安全审计完成！报告已保存到: $OUTPUT_FILE"
