#!/bin/bash
# 消息序列化测试脚本

set -e

MQ_TYPE=${1:-"kafka"}
FORMAT=${2:-"json"}

echo "=== 消息序列化测试 ==="
echo "系统: $MQ_TYPE"
echo "格式: $FORMAT"
echo ""

test_kafka_serialization() {
    echo "Kafka序列化测试:"
    echo "  支持的序列化格式:"
    echo "    - JSON: StringSerializer"
    echo "    - Avro: KafkaAvroSerializer"
    echo "    - Protobuf: 自定义Serializer"
    echo ""
    echo "  当前测试格式: $FORMAT"
    case $FORMAT in
        json)
            echo "    key.serializer: StringSerializer"
            echo "    value.serializer: StringSerializer"
            ;;
        avro)
            echo "    value.serializer: KafkaAvroSerializer"
            echo "    schema.registry.url: http://localhost:8081"
            ;;
        protobuf)
            echo "    value.serializer: ProtobufSerializer"
            ;;
    esac
}

test_nats_serialization() {
    echo "NATS序列化测试:"
    echo "  支持的序列化格式:"
    echo "    - JSON: encoding/json"
    echo "    - Protobuf: google.golang.org/protobuf"
    echo "    - MessagePack: 第三方库"
    echo ""
    echo "  当前测试格式: $FORMAT"
}

test_rabbitmq_serialization() {
    echo "RabbitMQ序列化测试:"
    echo "  支持的序列化格式:"
    echo "    - JSON: json模块"
    echo "    - Pickle: pickle模块"
    echo "    - MessagePack: msgpack库"
    echo ""
    echo "  当前测试格式: $FORMAT"
}

case $MQ_TYPE in
    kafka)
        test_kafka_serialization
        ;;
    nats)
        test_nats_serialization
        ;;
    rabbitmq)
        test_rabbitmq_serialization
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [json|avro|protobuf]"
        exit 1
        ;;
esac

echo ""
echo "消息序列化测试完成！"
