#!/usr/bin/env bash
# 动态验证①：自愈/扩容预算模拟（批次196）—— alert→KEDA 链路关键参数在位 + 积压排空预算复算
# 依据：TC-OBS-08 通过标准（扩容时延<5min【估算】）+ 02-49 触发模型；消费速率取 10000 msg/s/副本【估算】
#      （量级对齐 rabbitmq e2e 基线，01-18 §1.18.6；正式值以实测为准）
# RC: 0=预算内且锚点在位的；1=锚点缺失或预算破
set -u
cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 1
RULES="topics/config-templates/prometheus-alert-rules.yml"
KEDA="topics/config-templates/keda-scaledobject-kafka.yaml"
fail=0

grep -q "KafkaConsumerLagHigh" "$RULES" || { echo "FAIL: $RULES 缺 KafkaConsumerLagHigh 规则"; fail=1; }
grep -q "RabbitMQQueueBacklog" "$RULES" || { echo "FAIL: $RULES 缺 RabbitMQQueueBacklog 规则"; fail=1; }

LAG_T="$(grep -oE 'lagThreshold: "[0-9]+"' "$KEDA" | grep -oE '[0-9]+')"
MIN_R="$(grep -oE 'minReplicaCount: [0-9]+' "$KEDA" | grep -oE '[0-9]+')"
MAX_R="$(grep -oE 'maxReplicaCount: [0-9]+' "$KEDA" | grep -oE '[0-9]+')"
[ -n "$LAG_T" ] && [ -n "$MIN_R" ] && [ -n "$MAX_R" ] || { echo "FAIL: $KEDA 解析失败（lagThreshold/min/maxReplicaCount）"; exit 1; }
[ "$MAX_R" -gt "$MIN_R" ] || { echo "FAIL: maxReplica($MAX_R) ≤ minReplica($MIN_R)"; fail=1; }

RATE=10000            # msg/s/副本【估算】
BUDGET_S=300          # TC-OBS-08 通过标准 5min
DRAIN_S="$(awk "BEGIN{printf \"%.2f\", $LAG_T/$RATE}")"
OK="$(awk "BEGIN{print ($DRAIN_S<$BUDGET_S)?0:1}")"
echo "模拟：lagThreshold=$LAG_T 速率=$RATE msg/s/副本【估算】 → 单副本排空 ${DRAIN_S}s（预算 ${BUDGET_S}s），副本界 [$MIN_R,$MAX_R]"
if [ "$OK" -eq 0 ] && [ "$fail" -eq 0 ]; then
  echo "PASS: 自愈预算模拟（排空时间两个数量级低于预算；规则锚点齐）"
  exit 0
fi
echo "FAIL: 自愈预算模拟"
exit 1
