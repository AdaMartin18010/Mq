#!/bin/bash
# 数据治理检查脚本

set -e

OUTPUT_FILE=${1:-"data_governance_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 数据治理检查 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列数据治理检查报告 ==="
    echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "--- 数据分类检查 ---"
    echo "数据分类状态:"
    echo "  ⚠️  需根据业务需求分类数据"
    echo "  - 敏感度分类: 公开/内部/机密/绝密"
    echo "  - 业务分类: 交易/日志/配置/元数据"
    echo "  - 合规分类: GDPR/HIPAA/PCI"
    echo ""
    
    echo "--- 数据生命周期检查 ---"
    echo "生命周期管理:"
    
    # 检查保留策略
    if [ -f "kafka_*/config/server.properties" ]; then
        RETENTION=$(grep "log.retention" kafka_*/config/server.properties | head -1 || echo "未配置")
        echo "  Kafka保留策略: $RETENTION"
    fi
    
    echo "  ⚠️  需配置数据保留策略"
    echo "  - 创建: 数据产生和验证"
    echo "  - 存储: 数据存储和备份"
    echo "  - 使用: 数据访问和处理"
    echo "  - 销毁: 数据删除和清理"
    echo ""
    
    echo "--- 数据质量检查 ---"
    echo "数据质量指标:"
    echo "  - 完整性: 需验证"
    echo "  - 准确性: 需验证"
    echo "  - 一致性: 需验证"
    echo ""
    
    echo "--- 数据安全检查 ---"
    echo "数据安全措施:"
    
    # 检查加密
    if [ -f "kafka_*/config/server.properties" ]; then
        if grep -q "ssl.keystore.location" kafka_*/config/server.properties; then
            echo "  ✅ Kafka TLS加密已启用"
        else
            echo "  ❌ Kafka TLS加密未启用"
        fi
    fi
    
    echo "  - 传输加密: 需检查"
    echo "  - 存储加密: 需检查"
    echo "  - 访问控制: 需检查"
    echo "  - 数据脱敏: 需检查"
    echo ""
    
    echo "--- 数据治理建议 ---"
    echo "1. 建立数据分类标准"
    echo "2. 实施数据生命周期管理"
    echo "3. 建立数据质量标准"
    echo "4. 加强数据安全控制"
    echo "5. 定期数据治理审计"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "数据治理检查完成！报告已保存到: $OUTPUT_FILE"
