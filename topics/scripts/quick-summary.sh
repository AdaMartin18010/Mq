#!/bin/bash
# 快速项目摘要脚本

set -e

echo "=== 消息队列知识库项目摘要 ==="
echo ""

echo "--- 项目统计 ---"
TOTAL_DOCS=$(find . -name "*.md" -type f 2>/dev/null | wc -l)
TOTAL_SCRIPTS=$(find scripts -name "*.sh" -type f 2>/dev/null | wc -l)
TOTAL_CONFIGS=$(find config-templates -type f 2>/dev/null | wc -l)
TOTAL_FILES=$((TOTAL_DOCS + TOTAL_SCRIPTS + TOTAL_CONFIGS))

echo "  文档数: $TOTAL_DOCS"
echo "  脚本数: $TOTAL_SCRIPTS"
echo "  配置数: $TOTAL_CONFIGS"
echo "  总计: $TOTAL_FILES个文件"
echo ""

echo "--- 主要目录 ---"
echo "  01-基础概念与对比分析: $(find 01-基础概念与对比分析 -name "*.md" -type f 2>/dev/null | wc -l)个文档"
echo "  02-场景驱动架构设计: $(find 02-场景驱动架构设计 -name "*.md" -type f 2>/dev/null | wc -l)个文档"
echo "  03-架构与运维实践: $(find 03-架构与运维实践 -name "*.md" -type f 2>/dev/null | wc -l)个文档"
echo "  examples: $(find examples -type f 2>/dev/null | wc -l)个文件"
echo "  scripts: $TOTAL_SCRIPTS个脚本"
echo "  config-templates: $TOTAL_CONFIGS个配置"
echo ""

echo "--- 快速链接 ---"
echo "  主索引: INDEX.md"
echo "  项目状态: PROJECT_STATUS.md"
echo "  更新日志: CHANGELOG.md"
echo ""

echo "--- 系统覆盖 ---"
echo "  ✅ Kafka"
echo "  ✅ NATS (Core & JetStream)"
echo "  ✅ RabbitMQ"
echo "  ✅ MQTT"
echo "  ✅ Redis Stream"
echo "  ✅ Pulsar"
echo ""

echo "项目摘要生成完成！"
