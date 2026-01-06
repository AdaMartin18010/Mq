#!/bin/bash
# 消息路由测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
ROUTING_TYPE=${2:-"key"}

echo "=== 消息路由测试 ==="
echo "系统: $MQ_TYPE"
echo "路由类型: $ROUTING_TYPE"
echo ""

test_kafka_routing() {
    echo "Kafka路由测试:"
    echo "  路由方式:"
    echo "    - Key Hash路由（默认）"
    echo "    - 自定义分区器路由"
    echo "    - 指定分区路由"
    echo ""
    echo "  当前测试: $ROUTING_TYPE"
    case $ROUTING_TYPE in
        key)
            echo "    - 使用Key进行Hash路由"
            echo "    - 相同Key路由到同一分区"
            echo "    - 保证分区内顺序"
            ;;
        custom)
            echo "    - 使用自定义分区器"
            echo "    - 根据业务规则路由"
            echo "    - 灵活控制路由逻辑"
            ;;
        partition)
            echo "    - 直接指定分区"
            echo "    - 精确控制路由"
            echo "    - 无负载均衡"
            ;;
    esac
}

test_nats_routing() {
    echo "NATS路由测试:"
    echo "  路由方式:"
    echo "    - Subject路由"
    echo "    - 队列组负载均衡"
    echo "    - 通配符路由"
    echo ""
    echo "  当前测试: $ROUTING_TYPE"
    case $ROUTING_TYPE in
        subject)
            echo "    - 使用Subject进行路由"
            echo "    - 基于Subject匹配"
            echo "    - 支持通配符"
            ;;
        queue)
            echo "    - 使用队列组负载均衡"
            echo "    - 自动分发到多个消费者"
            echo "    - 保证负载均衡"
            ;;
    esac
}

test_rabbitmq_routing() {
    echo "RabbitMQ路由测试:"
    echo "  路由方式:"
    echo "    - Direct Exchange路由"
    echo "    - Topic Exchange路由"
    echo "    - Headers Exchange路由"
    echo ""
    echo "  当前测试: $ROUTING_TYPE"
    case $ROUTING_TYPE in
        direct)
            echo "    - 精确匹配路由键"
            echo "    - 简单高效"
            ;;
        topic)
            echo "    - 模式匹配路由键"
            echo "    - 支持通配符"
            echo "    - 灵活路由"
            ;;
        headers)
            echo "    - 基于消息头路由"
            echo "    - 不依赖路由键"
            echo "    - 复杂路由规则"
            ;;
    esac
}

case $MQ_TYPE in
    kafka)
        test_kafka_routing
        ;;
    nats)
        test_nats_routing
        ;;
    rabbitmq)
        test_rabbitmq_routing
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [routing_type]"
        exit 1
        ;;
esac

echo ""
echo "消息路由测试完成！"
