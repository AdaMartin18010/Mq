#!/bin/bash
# 死信重投（redrive）骨架 — mq-ops-dlq 技能配套
# 语义: 从 DLQ 读出消息 → 原样转发到目标 topic/queue → 确认后可选清理
# 注意: 执行前必须已完成根因修复；先 dry-run 核对再正式转发
set -e
SYSTEM=${1:-"kafka"}        # kafka | rabbitmq
DLQ=${2:-""}                # 死信 topic/queue
TARGET=${3:-""}             # 重投目标
DRY_RUN=${4:-"dry-run"}     # dry-run | commit

[ -z "$DLQ" ] || [ -z "$TARGET" ] && { echo "用法: $0 [kafka|rabbitmq] <dlq> <target> [dry-run|commit]"; exit 2; }

echo "=== DLQ 重投: $DLQ -> $TARGET（模式: $DRY_RUN）==="
echo "⚠️  确认根因已修复；dry-run 核对消息后再 commit"

case "$SYSTEM" in
  kafka)
    if [ "$DRY_RUN" = "dry-run" ]; then
      echo "[dry-run] 预览前 5 条死信:"
      kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic "$DLQ" \
        --from-beginning --max-messages 5 2>/dev/null
      echo "[dry-run] 数量统计: $(kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic "$DLQ" 2>/dev/null | awk -F: '{s+=$3} END{print s}') 条"
    else
      # commit：用 Kafka Connect/应用层转发；此处占位，禁止用简单管道丢失 header
      echo "❌ commit 模式须经由保留 header 的应用/连接器转发，本脚本不直接搬运"
      exit 1
    fi
    ;;
  rabbitmq)
    if [ "$DRY_RUN" = "dry-run" ]; then
      echo "[dry-run] 死信队列深度与样本:"
      rabbitmqadmin get queue="$DLQ" count=5 requeue=true
    else
      echo "❌ commit 模式须经由应用转发（保留 original-routing-keys），本脚本不直接搬运"
      exit 1
    fi
    ;;
  *) echo "用法: $0 [kafka|rabbitmq] <dlq> <target> [dry-run|commit]"; exit 2 ;;
esac
