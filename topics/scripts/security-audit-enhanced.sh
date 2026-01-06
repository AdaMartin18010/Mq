#!/bin/bash
# 增强版消息安全审计脚本

set -e

OUTPUT_FILE=${1:-"security-audit-report-$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息安全审计（增强版） ===" > "$OUTPUT_FILE"
echo "审计时间: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

audit_kafka_security() {
    echo "审计Kafka安全配置..." | tee -a "$OUTPUT_FILE"
    
    if command -v kafka-configs.sh &> /dev/null; then
        echo "  Kafka安全配置:" >> "$OUTPUT_FILE"
        
        # 检查SASL配置
        SASL_ENABLED=$(grep -i "sasl" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | wc -l)
        if [ "$SASL_ENABLED" -gt 0 ]; then
            echo "    ✅ SASL认证已启用" >> "$OUTPUT_FILE"
        else
            echo "    ⚠️  SASL认证未启用" >> "$OUTPUT_FILE"
        fi
        
        # 检查SSL配置
        SSL_ENABLED=$(grep -i "ssl" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | wc -l)
        if [ "$SSL_ENABLED" -gt 0 ]; then
            echo "    ✅ SSL/TLS加密已启用" >> "$OUTPUT_FILE"
        else
            echo "    ⚠️  SSL/TLS加密未启用" >> "$OUTPUT_FILE"
        fi
        
        # 检查ACL配置
        ACL_ENABLED=$(grep -i "authorizer" ${KAFKA_HOME:-/opt/kafka}/config/server.properties 2>/dev/null | wc -l)
        if [ "$ACL_ENABLED" -gt 0 ]; then
            echo "    ✅ ACL授权已启用" >> "$OUTPUT_FILE"
        else
            echo "    ⚠️  ACL授权未启用" >> "$OUTPUT_FILE"
        fi
    else
        echo "  ⚠️  Kafka未安装" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
}

audit_nats_security() {
    echo "审计NATS安全配置..." | tee -a "$OUTPUT_FILE"
    
    if docker ps | grep -q nats || command -v nats-server &> /dev/null; then
        echo "  NATS安全配置:" >> "$OUTPUT_FILE"
        echo "    - TLS/SSL: 检查配置文件" >> "$OUTPUT_FILE"
        echo "    - 认证: 检查用户配置" >> "$OUTPUT_FILE"
        echo "    - 授权: 检查权限配置" >> "$OUTPUT_FILE"
    else
        echo "  ⚠️  NATS未安装" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
}

audit_rabbitmq_security() {
    echo "审计RabbitMQ安全配置..." | tee -a "$OUTPUT_FILE"
    
    if docker ps | grep -q rabbitmq || command -v rabbitmqctl &> /dev/null; then
        echo "  RabbitMQ安全配置:" >> "$OUTPUT_FILE"
        
        # 检查默认用户
        DEFAULT_USER=$(docker exec rabbitmq rabbitmqctl list_users 2>/dev/null | \
            grep -E "guest|admin" | head -1 || echo "未知")
        if [ -n "$DEFAULT_USER" ]; then
            echo "    ⚠️  发现默认用户: $DEFAULT_USER" >> "$OUTPUT_FILE"
        fi
        
        # 检查SSL配置
        SSL_ENABLED=$(docker exec rabbitmq rabbitmqctl environment 2>/dev/null | \
            grep -i "ssl" | wc -l || echo "0")
        if [ "$SSL_ENABLED" -gt 0 ]; then
            echo "    ✅ SSL/TLS加密已启用" >> "$OUTPUT_FILE"
        else
            echo "    ⚠️  SSL/TLS加密未启用" >> "$OUTPUT_FILE"
        fi
    else
        echo "  ⚠️  RabbitMQ未安装" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
}

generate_security_recommendations() {
    echo "--- 安全建议 ---" >> "$OUTPUT_FILE"
    echo "1. 启用TLS/SSL传输加密" >> "$OUTPUT_FILE"
    echo "2. 配置强密码策略" >> "$OUTPUT_FILE"
    echo "3. 启用访问控制（ACL/RBAC）" >> "$OUTPUT_FILE"
    echo "4. 定期更新密钥和证书" >> "$OUTPUT_FILE"
    echo "5. 启用审计日志" >> "$OUTPUT_FILE"
    echo "6. 实施最小权限原则" >> "$OUTPUT_FILE"
    echo "7. 定期安全扫描" >> "$OUTPUT_FILE"
    echo "8. 建立安全响应流程" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

audit_kafka_security
audit_nats_security
audit_rabbitmq_security
generate_security_recommendations

echo "安全审计报告已生成: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
