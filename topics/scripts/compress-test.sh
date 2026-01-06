#!/bin/bash
# 压缩算法测试脚本

set -e

MESSAGE_SIZE=${1:-1024}  # 消息大小（KB）
MESSAGE_COUNT=${2:-1000}  # 消息数量

echo "=== 压缩算法性能测试 ==="
echo "消息大小: ${MESSAGE_SIZE}KB"
echo "消息数量: $MESSAGE_COUNT"
echo ""

# 生成测试数据
TEST_FILE="/tmp/test_data_${MESSAGE_SIZE}kb"
dd if=/dev/urandom of="$TEST_FILE" bs=1024 count=$MESSAGE_SIZE &> /dev/null

test_compression() {
    ALGORITHM=$1
    echo "测试 $ALGORITHM:"
    
    case $ALGORITHM in
        gzip)
            if command -v gzip &> /dev/null; then
                START_TIME=$(date +%s.%N)
                gzip -c "$TEST_FILE" > /tmp/test.gz
                END_TIME=$(date +%s.%N)
                ORIGINAL_SIZE=$(stat -f%z "$TEST_FILE" 2>/dev/null || stat -c%s "$TEST_FILE")
                COMPRESSED_SIZE=$(stat -f%z /tmp/test.gz 2>/dev/null || stat -c%s /tmp/test.gz)
                RATIO=$(echo "scale=2; $ORIGINAL_SIZE / $COMPRESSED_SIZE" | bc)
                TIME=$(echo "$END_TIME - $START_TIME" | bc)
                echo "  压缩比: ${RATIO}x"
                echo "  压缩时间: ${TIME}秒"
            fi
            ;;
        lz4)
            if command -v lz4 &> /dev/null; then
                START_TIME=$(date +%s.%N)
                lz4 -c "$TEST_FILE" > /tmp/test.lz4
                END_TIME=$(date +%s.%N)
                ORIGINAL_SIZE=$(stat -f%z "$TEST_FILE" 2>/dev/null || stat -c%s "$TEST_FILE")
                COMPRESSED_SIZE=$(stat -f%z /tmp/test.lz4 2>/dev/null || stat -c%s /tmp/test.lz4)
                RATIO=$(echo "scale=2; $ORIGINAL_SIZE / $COMPRESSED_SIZE" | bc)
                TIME=$(echo "$END_TIME - $START_TIME" | bc)
                echo "  压缩比: ${RATIO}x"
                echo "  压缩时间: ${TIME}秒"
            fi
            ;;
        snappy)
            echo "  ⚠️  需要安装snappy工具"
            ;;
    esac
    echo ""
}

test_compression gzip
test_compression lz4

# 清理
rm -f "$TEST_FILE" /tmp/test.gz /tmp/test.lz4

echo "压缩测试完成！"
