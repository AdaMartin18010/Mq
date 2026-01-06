#!/bin/bash
# 自动故障恢复脚本

set -e

MQ_TYPE=${1:-"all"}
MAX_RETRIES=${2:-3}

echo "=== 自动故障恢复 ==="
echo ""

recover_kafka() {
    echo "检查Kafka..."
    
    if ! ./scripts/health-check.sh kafka &> /dev/null; then
        echo "  ⚠️  Kafka健康检查失败，尝试恢复..."
        
        for i in $(seq 1 $MAX_RETRIES); do
            echo "  尝试 $i/$MAX_RETRIES: 重启Kafka..."
            ./scripts/restart.sh kafka
            
            sleep 5
            
            if ./scripts/health-check.sh kafka &> /dev/null; then
                echo "  ✅ Kafka恢复成功"
                return 0
            fi
        done
        
        echo "  ❌ Kafka恢复失败，需要人工介入"
        ./scripts/notify.sh "Kafka自动恢复失败" || true
        return 1
    else
        echo "  ✅ Kafka运行正常"
    fi
}

recover_nats() {
    echo "检查NATS..."
    
    if ! ./scripts/health-check.sh nats &> /dev/null; then
        echo "  ⚠️  NATS健康检查失败，尝试恢复..."
        
        for i in $(seq 1 $MAX_RETRIES); do
            echo "  尝试 $i/$MAX_RETRIES: 重启NATS..."
            ./scripts/restart.sh nats
            
            sleep 3
            
            if ./scripts/health-check.sh nats &> /dev/null; then
                echo "  ✅ NATS恢复成功"
                return 0
            fi
        done
        
        echo "  ❌ NATS恢复失败，需要人工介入"
        ./scripts/notify.sh "NATS自动恢复失败" || true
        return 1
    else
        echo "  ✅ NATS运行正常"
    fi
}

recover_rabbitmq() {
    echo "检查RabbitMQ..."
    
    if ! ./scripts/health-check.sh rabbitmq &> /dev/null; then
        echo "  ⚠️  RabbitMQ健康检查失败，尝试恢复..."
        
        for i in $(seq 1 $MAX_RETRIES); do
            echo "  尝试 $i/$MAX_RETRIES: 重启RabbitMQ..."
            ./scripts/restart.sh rabbitmq
            
            sleep 5
            
            if ./scripts/health-check.sh rabbitmq &> /dev/null; then
                echo "  ✅ RabbitMQ恢复成功"
                return 0
            fi
        done
        
        echo "  ❌ RabbitMQ恢复失败，需要人工介入"
        ./scripts/notify.sh "RabbitMQ自动恢复失败" || true
        return 1
    else
        echo "  ✅ RabbitMQ运行正常"
    fi
}

case $MQ_TYPE in
    kafka)
        recover_kafka
        ;;
    nats)
        recover_nats
        ;;
    rabbitmq)
        recover_rabbitmq
        ;;
    all)
        recover_kafka
        echo ""
        recover_nats
        echo ""
        recover_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq|all] [max_retries]"
        exit 1
        ;;
esac

echo ""
echo "自动恢复完成！"
