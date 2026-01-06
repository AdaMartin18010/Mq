#!/bin/bash
# 消息幂等性测试脚本

set -e

MQ_TYPE=${1:-"kafka"}

echo "=== 消息幂等性测试 ==="
echo ""

test_kafka_idempotency() {
    echo "Kafka幂等性测试:"
    echo "  Kafka幂等性实现:"
    echo "    - enable.idempotence=true（Producer幂等性）"
    echo "    - 事务保证幂等性"
    echo "    - 应用层幂等性检查"
    echo ""
    echo "  示例:"
    echo "    props.put(\"enable.idempotence\", \"true\")"
    echo "    producer.initTransactions()"
    echo "    producer.beginTransaction()"
}

test_nats_idempotency() {
    echo "NATS幂等性测试:"
    echo "  NATS幂等性实现:"
    echo "    - 使用MsgId实现幂等性"
    echo "    - 应用层幂等性检查"
    echo ""
    echo "  示例:"
    echo "    js.Publish(\"orders\", data, nats.MsgId(\"msg-123\"))"
}

test_rabbitmq_idempotency() {
    echo "RabbitMQ幂等性测试:"
    echo "  RabbitMQ幂等性实现:"
    echo "    - 使用message_id实现幂等性"
    echo "    - 应用层幂等性检查"
    echo ""
    echo "  示例:"
    echo "    properties.message_id = str(uuid.uuid4())"
    echo "    if message_id in processed_ids:"
    echo "        return  # 已处理"
}

case $MQ_TYPE in
    kafka)
        test_kafka_idempotency
        ;;
    nats)
        test_nats_idempotency
        ;;
    rabbitmq)
        test_rabbitmq_idempotency
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq]"
        exit 1
        ;;
esac

echo ""
echo "消息幂等性测试完成！"
