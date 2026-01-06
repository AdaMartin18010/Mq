#!/bin/bash
# 消息监控设置脚本

set -e

echo "=== 消息监控设置 ==="
echo ""

setup_prometheus() {
    echo "设置Prometheus监控..."
    
    if command -v prometheus &> /dev/null; then
        echo "  ✅ Prometheus已安装"
    else
        echo "  ⚠️  Prometheus未安装，请先安装Prometheus"
        echo "  安装命令:"
        echo "    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz"
        echo "    tar -xzf prometheus-2.45.0.linux-amd64.tar.gz"
        echo "    cd prometheus-2.45.0.linux-amd64"
        echo "    ./prometheus --config.file=prometheus.yml"
    fi
    
    echo ""
    echo "  Prometheus配置建议:"
    echo "    - 配置Kafka Exporter"
    echo "    - 配置NATS Exporter"
    echo "    - 配置RabbitMQ Exporter"
    echo "    - 配置告警规则"
}

setup_grafana() {
    echo "设置Grafana监控..."
    
    if command -v grafana-server &> /dev/null || docker ps | grep -q grafana; then
        echo "  ✅ Grafana已安装"
    else
        echo "  ⚠️  Grafana未安装，请先安装Grafana"
        echo "  安装命令:"
        echo "    docker run -d -p 3000:3000 grafana/grafana"
    fi
    
    echo ""
    echo "  Grafana配置建议:"
    echo "    - 添加Prometheus数据源"
    echo "    - 导入Kafka仪表板"
    echo "    - 导入NATS仪表板"
    echo "    - 导入RabbitMQ仪表板"
    echo "    - 配置告警通知"
}

setup_exporters() {
    echo "设置监控Exporter..."
    
    echo ""
    echo "  Kafka Exporter:"
    if docker ps | grep -q kafka-exporter; then
        echo "    ✅ Kafka Exporter运行中"
    else
        echo "    ⚠️  Kafka Exporter未运行"
        echo "    启动命令:"
        echo "      docker run -d -p 9308:9308 danielqsj/kafka-exporter --kafka.server=kafka:9092"
    fi
    
    echo ""
    echo "  NATS Exporter:"
    if docker ps | grep -q nats-exporter; then
        echo "    ✅ NATS Exporter运行中"
    else
        echo "    ⚠️  NATS Exporter未运行"
        echo "    启动命令:"
        echo "      docker run -d -p 7777:7777 natsio/prometheus-nats-exporter"
    fi
    
    echo ""
    echo "  RabbitMQ Exporter:"
    if docker ps | grep -q rabbitmq-exporter; then
        echo "    ✅ RabbitMQ Exporter运行中"
    else
        echo "    ⚠️  RabbitMQ Exporter未运行"
        echo "    启动命令:"
        echo "      docker run -d -p 9419:9419 kbudde/rabbitmq-exporter"
    fi
}

setup_prometheus
echo ""
setup_grafana
echo ""
setup_exporters

echo ""
echo "--- 监控建议 ---"
echo "1. 配置关键指标监控（吞吐量、延迟、错误率）"
echo "2. 设置合理的告警阈值"
echo "3. 设计清晰的监控仪表板"
echo "4. 定期检查监控数据"
echo "5. 优化监控性能"
echo "6. 建立监控告警响应流程"

echo ""
echo "消息监控设置完成！"
