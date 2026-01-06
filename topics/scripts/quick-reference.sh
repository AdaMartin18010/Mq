#!/bin/bash
# 快速参考脚本 - 显示常用命令和配置

set -e

echo "=== 消息队列快速参考 ==="
echo ""

show_kafka_commands() {
    echo "--- Kafka常用命令 ---"
    echo ""
    echo "Topic管理:"
    echo "  创建Topic:"
    echo "    kafka-topics.sh --create --topic <topic> --partitions <n> --replication-factor <n>"
    echo ""
    echo "  查看Topic:"
    echo "    kafka-topics.sh --list"
    echo "    kafka-topics.sh --describe --topic <topic>"
    echo ""
    echo "消息操作:"
    echo "  生产消息:"
    echo "    kafka-console-producer.sh --topic <topic> --bootstrap-server localhost:9092"
    echo ""
    echo "  消费消息:"
    echo "    kafka-console-consumer.sh --topic <topic> --from-beginning --bootstrap-server localhost:9092"
    echo ""
    echo "Consumer Group:"
    echo "    kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list"
    echo "    kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group <group>"
    echo ""
}

show_nats_commands() {
    echo "--- NATS常用命令 ---"
    echo ""
    echo "服务器:"
    echo "  启动: nats-server"
    echo "  配置: nats-server -c nats.conf"
    echo ""
    echo "消息操作:"
    echo "  发布: nats pub <subject> <message>"
    echo "  订阅: nats sub <subject>"
    echo ""
    echo "JetStream:"
    echo "  创建Stream: nats stream add"
    echo "  查看Stream: nats stream ls"
    echo ""
}

show_rabbitmq_commands() {
    echo "--- RabbitMQ常用命令 ---"
    echo ""
    echo "队列管理:"
    echo "  查看队列: rabbitmqctl list_queues"
    echo "  查看Exchange: rabbitmqctl list_exchanges"
    echo "  查看绑定: rabbitmqctl list_bindings"
    echo ""
    echo "用户管理:"
    echo "  创建用户: rabbitmqctl add_user <user> <password>"
    echo "  设置权限: rabbitmqctl set_permissions <user> \".*\" \".*\" \".*\""
    echo ""
    echo "管理界面:"
    echo "  http://localhost:15672 (默认: guest/guest)"
    echo ""
}

show_quick_links() {
    echo "--- 快速链接 ---"
    echo ""
    echo "文档:"
    echo "  快速参考卡片: topics/01-基础概念与对比分析/01-21-快速参考卡片.md"
    echo "  技术选型速查表: topics/01-基础概念与对比分析/01-20-技术选型速查表.md"
    echo "  常见问题FAQ: topics/01-基础概念与对比分析/01-22-常见问题FAQ.md"
    echo ""
    echo "脚本:"
    echo "  健康检查: ./scripts/health-check-all.sh"
    echo "  监控检查: ./scripts/monitor-check.sh"
    echo "  快速启动: ./scripts/quick-start.sh"
    echo ""
}

case "${1:-all}" in
    kafka)
        show_kafka_commands
        ;;
    nats)
        show_nats_commands
        ;;
    rabbitmq)
        show_rabbitmq_commands
        ;;
    all|*)
        show_kafka_commands
        echo ""
        show_nats_commands
        echo ""
        show_rabbitmq_commands
        echo ""
        show_quick_links
        ;;
esac
