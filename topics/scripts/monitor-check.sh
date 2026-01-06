#!/bin/bash
# 消息监控状态检查脚本

set -e

echo "=== 消息监控状态检查 ==="
echo ""

check_prometheus() {
    echo "检查Prometheus状态..."
    
    if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
        echo "  ✅ Prometheus运行中"
        TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>/dev/null | \
            jq -r '.data.activeTargets | length' 2>/dev/null || echo "未知")
        echo "  活动目标数: $TARGETS"
    else
        echo "  ⚠️  Prometheus未运行"
    fi
}

check_grafana() {
    echo "检查Grafana状态..."
    
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        echo "  ✅ Grafana运行中"
    elif docker ps | grep -q grafana; then
        echo "  ✅ Grafana容器运行中"
    else
        echo "  ⚠️  Grafana未运行"
    fi
}

check_exporters() {
    echo "检查监控Exporter状态..."
    
    echo ""
    echo "  Kafka Exporter:"
    if curl -s http://localhost:9308/metrics > /dev/null 2>&1; then
        echo "    ✅ Kafka Exporter运行中"
    elif docker ps | grep -q kafka-exporter; then
        echo "    ✅ Kafka Exporter容器运行中"
    else
        echo "    ⚠️  Kafka Exporter未运行"
    fi
    
    echo ""
    echo "  NATS Exporter:"
    if curl -s http://localhost:7777/metrics > /dev/null 2>&1; then
        echo "    ✅ NATS Exporter运行中"
    elif docker ps | grep -q nats-exporter; then
        echo "    ✅ NATS Exporter容器运行中"
    else
        echo "    ⚠️  NATS Exporter未运行"
    fi
    
    echo ""
    echo "  RabbitMQ Exporter:"
    if curl -s http://localhost:9419/metrics > /dev/null 2>&1; then
        echo "    ✅ RabbitMQ Exporter运行中"
    elif docker ps | grep -q rabbitmq-exporter; then
        echo "    ✅ RabbitMQ Exporter容器运行中"
    else
        echo "    ⚠️  RabbitMQ Exporter未运行"
    fi
}

check_alertmanager() {
    echo "检查AlertManager状态..."
    
    if curl -s http://localhost:9093/-/healthy > /dev/null 2>&1; then
        echo "  ✅ AlertManager运行中"
    elif docker ps | grep -q alertmanager; then
        echo "  ✅ AlertManager容器运行中"
    else
        echo "  ⚠️  AlertManager未运行"
    fi
}

check_prometheus
echo ""
check_grafana
echo ""
check_exporters
echo ""
check_alertmanager

echo ""
echo "--- 监控指标建议 ---"
echo "1. 吞吐量指标（消息生产/消费速率）"
echo "2. 延迟指标（生产延迟/消费延迟）"
echo "3. 错误率指标（错误消息数/总消息数）"
echo "4. 资源指标（CPU/内存/磁盘/网络）"
echo "5. 积压指标（未消费消息数）"
echo "6. 连接指标（活跃连接数）"

echo ""
echo "消息监控状态检查完成！"
