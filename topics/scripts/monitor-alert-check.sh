#!/bin/bash
# 消息监控告警检查脚本

set -e

echo "=== 消息监控告警检查 ==="
echo ""

check_monitoring_system() {
    echo "检查监控系统..."
    echo ""
    
    # 检查Prometheus
    if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
        echo "  ✅ Prometheus运行中"
    else
        echo "  ⚠️  Prometheus未运行"
    fi
    
    # 检查Grafana
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        echo "  ✅ Grafana运行中"
    else
        echo "  ⚠️  Grafana未运行"
    fi
    
    # 检查AlertManager
    if curl -s http://localhost:9093/-/healthy > /dev/null 2>&1; then
        echo "  ✅ AlertManager运行中"
    else
        echo "  ⚠️  AlertManager未运行"
    fi
}

check_exporters() {
    echo ""
    echo "检查Exporter..."
    echo ""
    
    # 检查Kafka Exporter
    if curl -s http://localhost:9308/metrics > /dev/null 2>&1; then
        echo "  ✅ Kafka Exporter运行中"
    else
        echo "  ⚠️  Kafka Exporter未运行"
    fi
    
    # 检查NATS Exporter
    if curl -s http://localhost:7777/metrics > /dev/null 2>&1; then
        echo "  ✅ NATS Exporter运行中"
    else
        echo "  ⚠️  NATS Exporter未运行"
    fi
    
    # 检查RabbitMQ Exporter
    if curl -s http://localhost:9419/metrics > /dev/null 2>&1; then
        echo "  ✅ RabbitMQ Exporter运行中"
    else
        echo "  ⚠️  RabbitMQ Exporter未运行"
    fi
}

check_alert_rules() {
    echo ""
    echo "检查告警规则..."
    echo ""
    echo "  --- 关键告警规则 ---"
    echo "  1. 高错误率告警: rate(errors_total[5m]) > 0.1"
    echo "  2. 高延迟告警: latency_p99 > 1000ms"
    echo "  3. 高吞吐量告警: throughput > 10000 msg/s"
    echo "  4. 资源告警: cpu_usage > 80%"
    echo "  5. 连接告警: connection_count < 1"
    echo ""
    echo "  --- 告警级别 ---"
    echo "  1. 紧急(Critical): 服务不可用"
    echo "  2. 警告(Warning): 性能下降"
    echo "  3. 信息(Info): 状态变化"
}

check_monitoring_system
check_exporters
check_alert_rules

echo ""
echo "--- 监控告警最佳实践 ---"
echo "1. 监控关键指标（吞吐量、延迟、错误率）"
echo "2. 设置合理的告警阈值"
echo "3. 使用多级告警（紧急/警告/信息）"
echo "4. 配置告警通知（邮件/短信/钉钉）"
echo "5. 定期审查和优化告警规则"

echo ""
echo "消息监控告警检查完成！"
