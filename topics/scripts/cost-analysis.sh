#!/bin/bash
# 成本分析脚本

set -e

OUTPUT_FILE=${1:-"cost_analysis_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 消息队列成本分析 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统成本分析报告 ==="
    echo "分析时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- 资源使用统计 ---"
    
    # CPU使用
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    echo "CPU使用率: ${CPU_USAGE}%"
    
    # 内存使用
    MEM_INFO=$(free -h | grep Mem)
    MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
    MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
    echo "内存使用: $MEM_USED / $MEM_TOTAL"
    
    # 磁盘使用
    DISK_INFO=$(df -h / | tail -1)
    DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')
    DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
    DISK_PERCENT=$(echo $DISK_INFO | awk '{print $5}')
    echo "磁盘使用: $DISK_USED / $DISK_TOTAL ($DISK_PERCENT)"
    echo ""
    
    echo "--- 成本估算 ---"
    echo "⚠️  以下为示例估算，实际成本需根据云服务商定价计算"
    echo ""
    echo "假设配置:"
    echo "  - 服务器: 3台（高可用）"
    echo "  - 规格: 8核16GB"
    echo "  - 存储: 1TB SSD"
    echo ""
    echo "月度成本估算（示例）:"
    echo "  - 计算资源: 约 $XXX"
    echo "  - 存储资源: 约 $XXX"
    echo "  - 网络流量: 约 $XXX"
    echo "  - 总计: 约 $XXX"
    echo ""
    
    echo "--- 优化建议 ---"
    echo "1. 合理规划资源，避免过度配置"
    echo "2. 启用数据压缩，减少存储成本"
    echo "3. 设置数据保留策略，定期清理旧数据"
    echo "4. 使用自动扩缩容，节省空闲资源"
    echo "5. 监控资源使用，持续优化"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "成本分析完成！报告已保存到: $OUTPUT_FILE"
