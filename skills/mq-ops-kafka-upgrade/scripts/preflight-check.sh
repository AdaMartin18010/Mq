#!/bin/bash
# Kafka 升级前预检（mq-ops-kafka-upgrade 技能配套）
# 权威参考: topics/scripts/upgrade-check.sh
set -e
BOOTSTRAP=${1:-"localhost:9092"}

echo "=== Kafka 升级前预检（bootstrap=$BOOTSTRAP）==="
FAIL=0

check() { # <描述> <命令>
  echo -n "[检查] $1 ... "
  if eval "$2" >/dev/null 2>&1; then echo "OK"; else echo "FAIL"; FAIL=$((FAIL+1)); fi
}

command -v kafka-topics.sh >/dev/null 2>&1 || { echo "❌ 未找到 kafka-topics.sh"; exit 1; }

echo -n "[信息] 当前版本: "
kafka-broker-api-versions.sh --bootstrap-server "$BOOTSTRAP" 2>/dev/null | head -1 || echo "unknown"

check "集群可访问" "kafka-topics.sh --list --bootstrap-server $BOOTSTRAP"
check "无 Under-replicated 分区" \
  "[ \$(kafka-topics.sh --describe --bootstrap-server $BOOTSTRAP 2>/dev/null | grep -c 'Under-replicated' || true) -eq 0 ]"
check "无离线分区" \
  "[ \$(kafka-topics.sh --describe --bootstrap-server $BOOTSTRAP 2>/dev/null | grep -c 'Leader: none' || true) -eq 0 ]"

echo -n "[检查] 配置备份 ... "
cp config/server.properties "config/server.properties.bak.$(date +%Y%m%d)" 2>/dev/null && echo "OK" || { echo "FAIL（手动备份 server.properties）"; FAIL=$((FAIL+1)); }

echo "============================="
[ "$FAIL" -eq 0 ] && echo "✅ 预检通过，可进入升级步骤" || echo "❌ $FAIL 项未通过，先修复再升级"
exit "$FAIL"
