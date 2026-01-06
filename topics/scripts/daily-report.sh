#!/bin/bash
# 每日报告生成脚本

set -e

OUTPUT_FILE=${1:-"daily_report_$(date +%Y%m%d).txt"}

echo "=== 生成每日报告 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统每日报告 ==="
    echo "报告日期: $(date '+%Y-%m-%d')"
    echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- 系统状态 ---"
    ./scripts/health-check-all.sh 2>/dev/null || echo "健康检查失败"
    echo ""
    
    echo "--- 健康评分 ---"
    ./scripts/health-score.sh all 2>/dev/null || echo "健康评分失败"
    echo ""
    
    echo "--- 资源使用 ---"
    ./scripts/resource-usage.sh all 2>/dev/null || echo "资源使用检查失败"
    echo ""
    
    echo "--- 容量检查 ---"
    ./scripts/capacity-check.sh all 2>/dev/null || echo "容量检查失败"
    echo ""
    
    echo "--- 告警检查 ---"
    ./scripts/alerts-check.sh all 2>/dev/null || echo "告警检查失败"
    echo ""
    
    echo "--- 性能指标 ---"
    ./scripts/metrics-compare.sh /dev/stdout 2>/dev/null || echo "指标对比失败"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo ""
echo "每日报告已生成: $OUTPUT_FILE"
