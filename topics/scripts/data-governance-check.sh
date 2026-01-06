#!/bin/bash
# 消息数据治理检查脚本

set -e

echo "=== 消息数据治理检查 ==="
echo ""

check_schema_management() {
    echo "检查Schema管理..."
    echo ""
    echo "  --- Schema Registry ---"
    if curl -s http://localhost:8081/subjects > /dev/null 2>&1; then
        echo "  ✅ Schema Registry运行中"
        SUBJECTS=$(curl -s http://localhost:8081/subjects 2>/dev/null | jq -r '.[]' 2>/dev/null || echo "")
        if [ -n "$SUBJECTS" ]; then
            echo ""
            echo "  已注册Schema:"
            echo "$SUBJECTS" | while read subject; do
                echo "    - $subject"
            done
        fi
    else
        echo "  ⚠️  Schema Registry未运行"
    fi
    echo ""
    echo "  --- Schema管理建议 ---"
    echo "  1. 使用Schema Registry管理Schema"
    echo "  2. 设置Schema兼容性策略"
    echo "  3. 实现Schema版本管理"
}

check_data_quality() {
    echo ""
    echo "检查数据质量..."
    echo ""
    echo "  --- 数据质量指标 ---"
    echo "  1. 数据完整性: 必填字段检查"
    echo "  2. 数据准确性: 数据格式验证"
    echo "  3. 数据一致性: 跨系统一致性"
    echo ""
    echo "  --- 数据质量检查 ---"
    echo "  1. Schema验证: 使用Schema验证数据"
    echo "  2. 业务规则验证: 自定义验证规则"
    echo "  3. 数据监控: 监控数据质量指标"
}

check_data_lifecycle() {
    echo ""
    echo "检查数据生命周期管理..."
    echo ""
    echo "  --- 数据保留策略 ---"
    echo "  1. 保留时间: 根据业务需求设置"
    echo "  2. 保留大小: 根据存储容量设置"
    echo "  3. 归档策略: 热数据/冷数据/归档数据"
    echo ""
    echo "  --- 数据清理 ---"
    echo "  1. 自动清理: 基于TTL自动清理"
    echo "  2. 手动清理: 按需手动清理"
    echo "  3. 归档清理: 归档后清理"
}

check_schema_management
check_data_quality
check_data_lifecycle

echo ""
echo "--- 数据治理最佳实践 ---"
echo "1. 使用Schema Registry管理Schema"
echo "2. 实现数据质量检查和监控"
echo "3. 建立数据生命周期管理策略"
echo "4. 确保数据合规性（隐私/安全）"
echo "5. 定期审计和优化数据治理策略"

echo ""
echo "消息数据治理检查完成！"
