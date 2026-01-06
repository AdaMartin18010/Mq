#!/bin/bash
# 消息队列配置验证脚本

set -e

MQ_TYPE=${1:-"kafka"}
CONFIG_FILE=${2:-""}

echo "=== 消息队列配置验证 ==="

validate_kafka_config() {
    echo "验证Kafka配置..."
    
    if [ -z "$CONFIG_FILE" ]; then
        CONFIG_FILE="kafka_*/config/server.properties"
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "  ❌ 配置文件不存在: $CONFIG_FILE"
        return 1
    fi
    
    # 检查关键配置
    echo "  检查关键配置项:"
    
    if grep -q "broker.id" "$CONFIG_FILE"; then
        echo "    ✅ broker.id已配置"
    else
        echo "    ❌ broker.id未配置"
    fi
    
    if grep -q "listeners" "$CONFIG_FILE"; then
        echo "    ✅ listeners已配置"
    else
        echo "    ❌ listeners未配置"
    fi
    
    if grep -q "log.dirs" "$CONFIG_FILE"; then
        echo "    ✅ log.dirs已配置"
    else
        echo "    ❌ log.dirs未配置"
    fi
    
    echo "  ✅ 配置验证完成"
}

validate_nats_config() {
    echo "验证NATS配置..."
    
    if [ -z "$CONFIG_FILE" ]; then
        CONFIG_FILE="nats-server.conf"
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "  ⚠️  配置文件不存在，使用默认配置"
        return 0
    fi
    
    echo "  ✅ 配置文件存在: $CONFIG_FILE"
    
    # 检查关键配置
    if grep -q "port" "$CONFIG_FILE"; then
        echo "    ✅ port已配置"
    fi
    
    if grep -q "http_port" "$CONFIG_FILE"; then
        echo "    ✅ http_port已配置"
    fi
}

validate_rabbitmq_config() {
    echo "验证RabbitMQ配置..."
    
    if [ -z "$CONFIG_FILE" ]; then
        CONFIG_FILE="rabbitmq.conf"
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "  ⚠️  配置文件不存在，使用默认配置"
        return 0
    fi
    
    echo "  ✅ 配置文件存在: $CONFIG_FILE"
}

case $MQ_TYPE in
    kafka)
        validate_kafka_config
        ;;
    nats)
        validate_nats_config
        ;;
    rabbitmq)
        validate_rabbitmq_config
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [config_file]"
        exit 1
        ;;
esac

echo "配置验证完成！"
