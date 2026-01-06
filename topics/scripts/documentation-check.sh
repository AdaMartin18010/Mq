#!/bin/bash
# 文档完整性检查脚本

set -e

echo "=== 文档完整性检查 ==="
echo ""

check_documentation() {
    echo "检查文档结构..."
    
    # 检查主要文档
    REQUIRED_FILES=(
        "INDEX.md"
        "PROJECT_STATUS.md"
        "CHANGELOG.md"
        "README.md"
    )
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file"
        else
            echo "  ❌ $file (缺失)"
        fi
    done
    
    echo ""
    echo "检查主题文档..."
    
    # 检查主题目录
    TOPIC_DIRS=(
        "01-基础概念与对比分析"
        "02-场景驱动架构设计"
        "03-架构与运维实践"
    )
    
    for dir in "${TOPIC_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            COUNT=$(find "$dir" -name "*.md" -type f | wc -l)
            echo "  ✅ $dir ($COUNT个文件)"
        else
            echo "  ❌ $dir (缺失)"
        fi
    done
    
    echo ""
    echo "检查脚本文档..."
    
    if [ -f "scripts/README.md" ]; then
        SCRIPT_COUNT=$(find scripts -name "*.sh" -type f | wc -l)
        echo "  ✅ scripts/README.md ($SCRIPT_COUNT个脚本)"
    else
        echo "  ❌ scripts/README.md (缺失)"
    fi
    
    echo ""
    echo "检查配置模板文档..."
    
    if [ -f "config-templates/README.md" ]; then
        CONFIG_COUNT=$(find config-templates -name "*.properties" -o -name "*.conf" -o -name "*.yml" -o -name "*.json" | wc -l)
        echo "  ✅ config-templates/README.md ($CONFIG_COUNT个配置)"
    else
        echo "  ❌ config-templates/README.md (缺失)"
    fi
}

check_documentation

echo ""
echo "文档完整性检查完成！"
