#!/bin/bash
# 消息版本兼容性检查脚本

set -e

echo "=== 消息版本兼容性检查 ==="
echo ""

check_schema_registry_compatibility() {
    echo "检查Schema Registry兼容性..."
    
    if curl -s http://localhost:8081/subjects > /dev/null 2>&1; then
        echo "  ✅ Schema Registry运行中"
        
        # 检查兼容性级别
        SUBJECTS=$(curl -s http://localhost:8081/subjects 2>/dev/null | jq -r '.[]' 2>/dev/null)
        if [ -n "$SUBJECTS" ]; then
            echo ""
            echo "  Schema兼容性级别:"
            echo "$SUBJECTS" | while read subject; do
                COMPATIBILITY=$(curl -s "http://localhost:8081/config/$subject" 2>/dev/null | \
                    jq -r '.compatibilityLevel' 2>/dev/null || echo "未知")
                echo "    - $subject: $COMPATIBILITY"
            done
        fi
    else
        echo "  ⚠️  Schema Registry未运行"
    fi
}

check_message_versions() {
    echo ""
    echo "检查消息版本..."
    echo "  --- 版本兼容建议 ---"
    echo "  1. 使用语义化版本（主版本.次版本.修订版本）"
    echo "  2. 向前兼容：新字段可选，字段删除需谨慎"
    echo "  3. 向后兼容：旧版本支持，降级策略"
    echo "  4. 不兼容变更：版本升级，迁移策略"
    echo ""
    echo "  --- 版本管理建议 ---"
    echo "  1. Schema Registry管理Schema版本"
    echo "  2. 消息头包含版本信息"
    echo "  3. 版本路由和兼容处理"
    echo "  4. 渐进式迁移策略"
}

check_schema_registry_compatibility
check_message_versions

echo ""
echo "--- 迁移建议 ---"
echo "1. 渐进式迁移（双写策略）"
echo "2. 版本共存（多版本支持）"
echo "3. 快速迁移（一次性迁移）"
echo "4. 版本降级策略"
echo "5. 迁移验证和回滚"

echo ""
echo "消息版本兼容性检查完成！"
