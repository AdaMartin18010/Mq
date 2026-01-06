#!/bin/bash
# 安全扫描脚本

set -e

MQ_TYPE=${1:-"all"}
OUTPUT_FILE=${2:-"security_scan_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息队列安全扫描 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统安全扫描报告 ==="
    echo "扫描时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    scan_kafka() {
        echo "--- Kafka安全扫描 ---"
        
        # 检查配置文件
        if [ -f "kafka_*/config/server.properties" ]; then
            CONFIG="kafka_*/config/server.properties"
            
            # 检查SASL
            if grep -q "sasl.enabled.mechanisms" "$CONFIG"; then
                echo "✅ SASL认证已启用"
            else
                echo "❌ SASL认证未启用（安全风险）"
            fi
            
            # 检查SSL
            if grep -q "ssl.keystore.location" "$CONFIG"; then
                echo "✅ SSL加密已启用"
            else
                echo "❌ SSL加密未启用（安全风险）"
            fi
            
            # 检查ACL
            if grep -q "authorizer.class.name" "$CONFIG"; then
                echo "✅ ACL授权已配置"
            else
                echo "❌ ACL授权未配置（安全风险）"
            fi
            
            # 检查匿名访问
            if grep -q "allow.everyone.if.no.acl.found" "$CONFIG"; then
                ALLOW=$(grep "allow.everyone.if.no.acl.found" "$CONFIG" | cut -d= -f2 | tr -d ' ')
                if [ "$ALLOW" = "true" ]; then
                    echo "⚠️  允许匿名访问（安全风险）"
                fi
            fi
        fi
        echo ""
    }
    
    scan_nats() {
        echo "--- NATS安全扫描 ---"
        
        if [ -f "nats-server.conf" ]; then
            CONFIG="nats-server.conf"
            
            # 检查TLS
            if grep -q "tls {" "$CONFIG"; then
                echo "✅ TLS加密已启用"
            else
                echo "❌ TLS加密未启用（安全风险）"
            fi
            
            # 检查认证
            if grep -q "authorization" "$CONFIG"; then
                echo "✅ 认证已配置"
            else
                echo "❌ 认证未配置（安全风险）"
            fi
        else
            echo "⚠️  使用默认配置（建议配置TLS和认证）"
        fi
        echo ""
    }
    
    scan_rabbitmq() {
        echo "--- RabbitMQ安全扫描 ---"
        
        if docker ps | grep -q rabbitmq; then
            # 检查用户
            USERS=$(docker exec rabbitmq rabbitmqctl list_users 2>/dev/null | wc -l)
            if [ "$USERS" -gt 1 ]; then
                echo "✅ 已配置用户（$USERS个）"
            else
                echo "❌ 仅使用默认用户（安全风险）"
            fi
            
            # 检查guest用户
            if docker exec rabbitmq rabbitmqctl list_users 2>/dev/null | grep -q guest; then
                echo "⚠️  guest用户仍存在（建议禁用）"
            fi
            
            # 检查TLS
            if docker exec rabbitmq rabbitmqctl environment 2>/dev/null | grep -q ssl; then
                echo "✅ TLS加密已启用"
            else
                echo "❌ TLS加密未启用（安全风险）"
            fi
        fi
        echo ""
    }
    
    case $MQ_TYPE in
        kafka)
            scan_kafka
            ;;
        nats)
            scan_nats
            ;;
        rabbitmq)
            scan_rabbitmq
            ;;
        all)
            scan_kafka
            scan_nats
            scan_rabbitmq
            ;;
        *)
            echo "用法: $0 [kafka|nats|rabbitmq|all] [output_file]"
            exit 1
            ;;
    esac
    
    echo "--- 安全建议 ---"
    echo "1. 启用TLS/SSL加密"
    echo "2. 配置认证和授权"
    echo "3. 禁用匿名访问"
    echo "4. 定期更新密码和证书"
    echo "5. 监控异常访问"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "安全扫描完成！报告已保存到: $OUTPUT_FILE"
