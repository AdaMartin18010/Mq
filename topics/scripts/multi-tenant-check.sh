#!/bin/bash
# 多租户配置检查脚本

set -e

echo "=== 多租户配置检查 ==="
echo ""

check_multi_tenant() {
    echo "检查多租户配置..."
    
    echo ""
    echo "--- Kafka多租户 ---"
    if [ -f "kafka_*/config/server.properties" ]; then
        if grep -q "quota.producer" kafka_*/config/server.properties; then
            echo "  ✅ 配额配置已设置"
        else
            echo "  ⚠️  配额配置未设置"
        fi
        
        if grep -q "authorizer.class.name" kafka_*/config/server.properties; then
            echo "  ✅ ACL授权已配置"
        else
            echo "  ⚠️  ACL授权未配置"
        fi
    else
        echo "  ⚠️  Kafka配置文件未找到"
    fi
    
    echo ""
    echo "--- NATS多租户 ---"
    echo "  ⚠️  需检查账户和Stream配置"
    echo "  - 账户隔离"
    echo "  - Subject命名隔离"
    echo "  - Stream配置隔离"
    
    echo ""
    echo "--- RabbitMQ多租户 ---"
    if docker ps | grep -q rabbitmq; then
        VHOSTS=$(docker exec rabbitmq rabbitmqctl list_vhosts 2>/dev/null | wc -l)
        echo "  Virtual Hosts: $VHOSTS"
    elif command -v rabbitmqctl &> /dev/null; then
        VHOSTS=$(rabbitmqctl list_vhosts 2>/dev/null | wc -l)
        echo "  Virtual Hosts: $VHOSTS"
    else
        echo "  ⚠️  RabbitMQ未安装"
    fi
    
    echo ""
    echo "--- 多租户建议 ---"
    echo "1. 明确隔离级别（完全/逻辑/混合）"
    echo "2. 配置资源配额"
    echo "3. 设置权限控制"
    echo "4. 监控租户资源使用"
    echo "5. 审计租户操作"
}

check_multi_tenant

echo ""
echo "多租户配置检查完成！"
