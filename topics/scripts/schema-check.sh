#!/bin/bash
# Schema版本检查脚本

set -e

echo "=== Schema版本检查 ==="
echo ""

check_schema_registry() {
    echo "检查Schema Registry..."
    
    # 检查Confluent Schema Registry
    if curl -s http://localhost:8081/subjects > /dev/null 2>&1; then
        echo "  ✅ Schema Registry运行中"
        SUBJECTS=$(curl -s http://localhost:8081/subjects | jq -r '.[]' 2>/dev/null | wc -l)
        echo "  Subjects数量: $SUBJECTS"
    else
        echo "  ⚠️  Schema Registry未运行或未安装"
    fi
    
    echo ""
    echo "--- Schema管理建议 ---"
    echo "1. 使用Schema Registry管理Schema"
    echo "2. 定义Schema版本策略"
    echo "3. 配置兼容性规则"
    echo "4. 定期Schema审核"
    echo "5. 维护Schema文档"
    echo ""
    
    echo "--- 序列化格式建议 ---"
    echo "1. JSON: 开发调试、小数据量"
    echo "2. Avro: 大数据量、Schema演进"
    echo "3. Protobuf: 高性能、跨语言"
}

check_schema_registry

echo ""
echo "Schema版本检查完成！"
