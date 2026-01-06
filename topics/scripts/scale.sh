#!/bin/bash
# 消息队列扩缩容脚本

set -e

MQ_TYPE=${1:-"kafka"}
ACTION=${2:-"scale-up"}
COUNT=${3:-1}

echo "=== 消息队列扩缩容 ==="

scale_kafka() {
    case $ACTION in
        scale-up)
            echo "扩展Kafka集群..."
            # 添加新的Broker节点
            echo "添加Broker节点（需要手动配置）"
            ;;
        scale-down)
            echo "缩减Kafka集群..."
            # 移除Broker节点
            echo "移除Broker节点（需要手动配置）"
            ;;
    esac
}

scale_nats() {
    case $ACTION in
        scale-up)
            echo "扩展NATS集群..."
            # 使用Docker Compose扩展
            if [ -f "docker-compose-nats.yml" ]; then
                docker-compose -f docker-compose-nats.yml up -d --scale nats=$COUNT
            else
                echo "需要docker-compose-nats.yml配置文件"
            fi
            ;;
        scale-down)
            echo "缩减NATS集群..."
            docker-compose -f docker-compose-nats.yml up -d --scale nats=$COUNT
            ;;
    esac
}

scale_rabbitmq() {
    case $ACTION in
        scale-up)
            echo "扩展RabbitMQ集群..."
            # 添加节点到集群
            echo "添加RabbitMQ节点（需要手动配置）"
            ;;
        scale-down)
            echo "缩减RabbitMQ集群..."
            echo "移除RabbitMQ节点（需要手动配置）"
            ;;
    esac
}

case $MQ_TYPE in
    kafka)
        scale_kafka
        ;;
    nats)
        scale_nats
        ;;
    rabbitmq)
        scale_rabbitmq
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [scale-up|scale-down] [count]"
        exit 1
        ;;
esac

echo "扩缩容完成！"
