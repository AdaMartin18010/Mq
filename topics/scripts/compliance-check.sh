#!/bin/bash
# 合规性检查脚本

set -e

COMPLIANCE_TYPE=${1:-"all"}
OUTPUT_FILE=${2:-"compliance_check_$(date +%Y%m%d_%H%M%S).txt"}

echo "=== 合规性检查 ==="
echo "输出文件: $OUTPUT_FILE"
echo ""

{
    echo "=== 消息队列系统合规性检查报告 ==="
    echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "合规标准: $COMPLIANCE_TYPE"
    echo ""
    
    check_gdpr() {
        echo "--- GDPR合规检查 ---"
        
        # 检查数据加密
        echo "数据加密:"
        if [ -f "kafka_*/config/server.properties" ]; then
            if grep -q "ssl.keystore.location" kafka_*/config/server.properties; then
                echo "  ✅ Kafka TLS加密已启用"
            else
                echo "  ❌ Kafka TLS加密未启用"
            fi
        fi
        
        # 检查访问控制
        echo "访问控制:"
        if [ -f "kafka_*/config/server.properties" ]; then
            if grep -q "authorizer.class.name" kafka_*/config/server.properties; then
                echo "  ✅ Kafka ACL授权已配置"
            else
                echo "  ❌ Kafka ACL授权未配置"
            fi
        fi
        
        echo ""
    }
    
    check_hipaa() {
        echo "--- HIPAA合规检查 ---"
        
        # 检查审计日志
        echo "审计日志:"
        if [ -d "kafka_*/logs" ]; then
            echo "  ✅ Kafka日志已启用"
        else
            echo "  ⚠️  Kafka日志配置需检查"
        fi
        
        # 检查数据备份
        echo "数据备份:"
        if [ -f "scripts/backup-all.sh" ]; then
            echo "  ✅ 备份脚本已配置"
        else
            echo "  ⚠️  备份脚本需配置"
        fi
        
        echo ""
    }
    
    check_pci_dss() {
        echo "--- PCI DSS合规检查 ---"
        
        # 检查数据加密
        echo "数据加密:"
        echo "  ⚠️  需确保支付数据加密"
        
        # 检查访问控制
        echo "访问控制:"
        echo "  ⚠️  需确保严格的访问控制"
        
        echo ""
    }
    
    case $COMPLIANCE_TYPE in
        gdpr)
            check_gdpr
            ;;
        hipaa)
            check_hipaa
            ;;
        pci)
            check_pci_dss
            ;;
        all)
            check_gdpr
            check_hipaa
            check_pci_dss
            ;;
        *)
            echo "用法: $0 [gdpr|hipaa|pci|all] [output_file]"
            exit 1
            ;;
    esac
    
    echo "--- 合规建议 ---"
    echo "1. 启用数据加密（传输和存储）"
    echo "2. 配置访问控制和审计"
    echo "3. 定期安全审计"
    echo "4. 数据备份和恢复机制"
    echo "5. 合规文档和流程"
    echo ""
    
} | tee "$OUTPUT_FILE"

echo "合规性检查完成！报告已保存到: $OUTPUT_FILE"
