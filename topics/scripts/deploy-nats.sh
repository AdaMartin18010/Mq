#!/bin/bash
# NATS快速部署脚本

set -e

NATS_VERSION="2.10.0"
NATS_DIR="nats-server-v${NATS_VERSION}-linux-amd64"
NATS_URL="https://github.com/nats-io/nats-server/releases/download/v${NATS_VERSION}/${NATS_DIR}.zip"

echo "=== NATS部署脚本 ==="

# 下载NATS
if [ ! -d "$NATS_DIR" ]; then
    echo "下载NATS ${NATS_VERSION}..."
    if command -v wget &> /dev/null; then
        wget "$NATS_URL" -O nats.zip
    elif command -v curl &> /dev/null; then
        curl -L "$NATS_URL" -o nats.zip
    else
        echo "错误: 需要wget或curl"
        exit 1
    fi
    
    unzip nats.zip
    rm nats.zip
fi

# 启动NATS Server
echo "启动NATS Server..."
cd "$NATS_DIR"
./nats-server &

echo "NATS部署完成！"
echo "管理端口: http://localhost:8222"
echo "停止服务: pkill nats-server"
