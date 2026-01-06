#!/bin/bash
# 清理旧数据脚本

set -e

MQ_TYPE=${1:-"kafka"}
RETENTION_DAYS=${2:-7}

echo "=== 清理旧数据 ==="
echo "保留天数: $RETENTION_DAYS"
echo "⚠️  警告：此操作将删除旧数据！"
read -p "确认继续？(yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

cleanup_kafka() {
    echo "清理Kafka旧数据..."
    
    if command -v kafka-configs.sh &> /dev/null; then
        # 设置保留策略
        kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | \
            while read topic; do
                kafka-configs.sh --alter --topic "$topic" \
                    --bootstrap-server localhost:9092 \
                    --add-config retention.ms=$((RETENTION_DAYS * 24 * 60 * 60 * 1000)) \
                    2>/dev/null || true
            done
        echo "  ✅ Kafka保留策略已更新"
    else
        echo "  ⚠️  需要kafka-configs.sh工具"
    fi
}

cleanup_nats() {
    echo "清理NATS旧数据..."
    echo "  ⚠️  NATS Core模式无持久化数据"
    echo "  JetStream数据清理需要手动配置"
}

cleanup_rabbitmq() {
    echo "清理RabbitMQ旧数据..."
    
    if docker ps | grep -q rabbitmq; then
        # 清理过期消息（需要配置TTL）
        echo "  ⚠️  需要配置队列TTL策略"
    else
        echo "  ⚠️  RabbitMQ未运行"
    fi
}

case $MQ_TYPE in
    kafka)
        cleanup_kafka
        ;;
    nats)
        cleanup_nats
        ;;
    rabbitmq)
        cleanup_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [retention_days]"
        exit 1
        ;;
esac

echo ""
echo "清理完成！"
