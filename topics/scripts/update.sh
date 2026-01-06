#!/bin/bash
# 消息队列升级脚本

set -e

MQ_TYPE=${1:-"kafka"}
VERSION=${2:-"latest"}

echo "=== 消息队列升级 ==="

update_kafka() {
    echo "升级Kafka到版本: $VERSION"
    
    # 备份当前配置
    if [ -d "kafka_*" ]; then
        KAFKA_DIR=$(ls -d kafka_* | head -1)
        cp -r "$KAFKA_DIR/config" "$KAFKA_DIR/config.backup"
        echo "✅ 配置已备份"
    fi
    
    # 下载新版本
    echo "下载Kafka $VERSION..."
    # wget https://downloads.apache.org/kafka/$VERSION/kafka_2.13-$VERSION.tgz
    
    echo "⚠️  请手动完成升级步骤："
    echo "1. 停止Kafka服务"
    echo "2. 解压新版本"
    echo "3. 恢复配置文件"
    echo "4. 启动Kafka服务"
}

update_nats() {
    echo "升级NATS到版本: $VERSION"
    
    if command -v docker &> /dev/null; then
        docker pull nats:$VERSION
        echo "✅ NATS镜像已更新"
        echo "重启容器以应用新版本"
    else
        echo "⚠️  请手动升级NATS Server"
    fi
}

update_rabbitmq() {
    echo "升级RabbitMQ到版本: $VERSION"
    
    if command -v docker &> /dev/null; then
        docker pull rabbitmq:$VERSION-management
        echo "✅ RabbitMQ镜像已更新"
        echo "重启容器以应用新版本"
    else
        echo "⚠️  请手动升级RabbitMQ"
    fi
}

case $MQ_TYPE in
    kafka)
        update_kafka
        ;;
    nats)
        update_nats
        ;;
    rabbitmq)
        update_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [version]"
        exit 1
        ;;
esac

echo "升级完成！"
