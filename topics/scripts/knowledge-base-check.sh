#!/bin/bash
# 知识库完整性检查脚本

set -e

echo "=== 知识库完整性检查 ==="
echo ""

check_knowledge_base() {
    echo "检查知识库结构..."
    
    # 检查主要目录
    MAIN_DIRS=(
        "01-基础概念与对比分析"
        "02-场景驱动架构设计"
        "03-架构与运维实践"
        "examples"
        "scripts"
        "config-templates"
    )
    
    for dir in "${MAIN_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            FILE_COUNT=$(find "$dir" -type f | wc -l)
            echo "  ✅ $dir ($FILE_COUNT个文件)"
        else
            echo "  ❌ $dir (缺失)"
        fi
    done
    
    echo ""
    echo "检查索引文件..."
    
    INDEX_FILES=(
        "INDEX.md"
        "PROJECT_STATUS.md"
        "CHANGELOG.md"
    )
    
    for file in "${INDEX_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file"
        else
            echo "  ❌ $file (缺失)"
        fi
    done
    
    echo ""
    echo "检查README文件..."
    
    README_FILES=(
        "README.md"
        "01-基础概念与对比分析/README.md"
        "02-场景驱动架构设计/README.md"
        "03-架构与运维实践/README.md"
        "scripts/README.md"
        "config-templates/README.md"
    )
    
    for file in "${README_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  ✅ $file"
        else
            echo "  ⚠️  $file (缺失，建议创建)"
        fi
    done
    
    echo ""
    echo "统计知识库内容..."
    
    TOTAL_DOCS=$(find . -name "*.md" -type f | wc -l)
    TOTAL_SCRIPTS=$(find scripts -name "*.sh" -type f 2>/dev/null | wc -l)
    TOTAL_CONFIGS=$(find config-templates -type f 2>/dev/null | wc -l)
    
    echo "  总文档数: $TOTAL_DOCS"
    echo "  总脚本数: $TOTAL_SCRIPTS"
    echo "  总配置数: $TOTAL_CONFIGS"
    echo "  总计: $((TOTAL_DOCS + TOTAL_SCRIPTS + TOTAL_CONFIGS))个文件"
}

check_knowledge_base

echo ""
echo "知识库完整性检查完成！"
