#!/bin/bash
# 故障注入测试脚本（混沌工程）

set -e

echo "=== 消息队列故障注入测试 ==="

TEST_TYPE=${1:-"kafka"}
SCENARIO=${2:-"network"}

case $TEST_TYPE in
    kafka)
        echo "Kafka故障注入测试 - 场景: $SCENARIO"
        case $SCENARIO in
            network)
                echo "模拟网络延迟..."
                # 使用tc命令添加网络延迟
                if command -v tc &> /dev/null; then
                    sudo tc qdisc add dev lo root netem delay 100ms
                    echo "已添加100ms网络延迟，按Ctrl+C停止"
                    sleep 60
                    sudo tc qdisc del dev lo root
                else
                    echo "需要安装iproute2: sudo apt-get install iproute2"
                fi
                ;;
            partition)
                echo "模拟分区故障..."
                # 停止部分Broker
                echo "停止Broker 2..."
                # pkill -f "kafka-server.*broker.id=2"
                ;;
            disk)
                echo "模拟磁盘故障..."
                # 使用faulty模拟磁盘故障
                echo "使用faulty块设备模拟磁盘故障"
                ;;
        esac
        ;;
    nats)
        echo "NATS故障注入测试 - 场景: $SCENARIO"
        case $SCENARIO in
            network)
                echo "模拟网络延迟..."
                if command -v tc &> /dev/null; then
                    sudo tc qdisc add dev lo root netem delay 50ms
                    sleep 60
                    sudo tc qdisc del dev lo root
                fi
                ;;
            server)
                echo "模拟服务器故障..."
                # pkill -f nats-server
                ;;
        esac
        ;;
    rabbitmq)
        echo "RabbitMQ故障注入测试 - 场景: $SCENARIO"
        case $SCENARIO in
            network)
                echo "模拟网络延迟..."
                if command -v tc &> /dev/null; then
                    sudo tc qdisc add dev lo root netem delay 50ms
                    sleep 60
                    sudo tc qdisc del dev lo root
                fi
                ;;
            node)
                echo "模拟节点故障..."
                # docker stop rabbitmq
                ;;
        esac
        ;;
    *)
        echo "用法: $0 [kafka|nats|rabbitmq] [network|partition|disk|server|node]"
        exit 1
        ;;
esac

echo "故障注入测试完成！"
