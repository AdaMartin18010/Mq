#!/bin/bash
# RabbitMQ快速部署脚本

set -e

echo "=== RabbitMQ部署脚本 ==="

# 检查Docker
if command -v docker &> /dev/null; then
    echo "使用Docker部署RabbitMQ..."
    docker run -d \
        --name rabbitmq \
        -p 5672:5672 \
        -p 15672:15672 \
        -e RABBITMQ_DEFAULT_USER=admin \
        -e RABBITMQ_DEFAULT_PASS=admin \
        rabbitmq:3-management
    
    echo "RabbitMQ部署完成！"
    echo "管理界面: http://localhost:15672"
    echo "用户名: admin, 密码: admin"
    exit 0
fi

# 检查是否已安装
if command -v rabbitmq-server &> /dev/null; then
    echo "启动RabbitMQ Server..."
    rabbitmq-server &
    echo "RabbitMQ部署完成！"
    exit 0
fi

echo "错误: 未找到Docker或RabbitMQ，请先安装"
echo "Docker: docker pull rabbitmq:3-management"
echo "或安装RabbitMQ: https://www.rabbitmq.com/download.html"
