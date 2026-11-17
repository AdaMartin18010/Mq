#!/bin/bash
# mq-ops-dlq 监控脚本（薄封装）
# 权威版本: topics/scripts/dlq-monitor.sh
set -e
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
exec bash "$ROOT/topics/scripts/dlq-monitor.sh" "$@"
