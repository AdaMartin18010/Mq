#!/bin/bash
# 快速重启脚本（一键重启所有消息队列系统）

set -e

echo "=== 消息队列系统快速重启 ==="
echo ""

# 先停止
echo "停止服务..."
./scripts/quick-stop.sh 2>/dev/null || true

echo ""
echo "等待服务完全停止..."
sleep 3

# 再启动
echo "启动服务..."
./scripts/quick-start.sh

echo ""
echo "快速重启完成！"
