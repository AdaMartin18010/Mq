#!/bin/bash
# Kafka快速部署脚本

set -e

KAFKA_VERSION="3.5.0"
KAFKA_DIR="kafka_2.13-${KAFKA_VERSION}"
KAFKA_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION}/${KAFKA_DIR}.tgz"

echo "=== Kafka部署脚本 ==="

# 检查Java
if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java，请先安装Java 11+"
    exit 1
fi

# 下载Kafka
if [ ! -d "$KAFKA_DIR" ]; then
    echo "下载Kafka ${KAFKA_VERSION}..."
    wget "$KAFKA_URL" -O kafka.tgz
    tar -xzf kafka.tgz
    rm kafka.tgz
fi

# 配置Kafka
echo "配置Kafka..."
cd "$KAFKA_DIR"

# 创建日志目录
mkdir -p logs

# 启动ZooKeeper（如果使用KRaft模式则跳过）
if [ "$1" != "kraft" ]; then
    echo "启动ZooKeeper..."
    bin/zookeeper-server-start.sh config/zookeeper.properties &
    sleep 5
fi

# 启动Kafka Broker
echo "启动Kafka Broker..."
if [ "$1" == "kraft" ]; then
    # KRaft模式
    bin/kafka-storage.sh format -t $(bin/kafka-storage.sh random-uuid) -c config/kraft/server.properties
    bin/kafka-server-start.sh config/kraft/server.properties &
else
    # 传统模式
    bin/kafka-server-start.sh config/server.properties &
fi

echo "Kafka部署完成！"
echo "管理工具: bin/kafka-topics.sh"
echo "停止服务: bin/kafka-server-stop.sh"
