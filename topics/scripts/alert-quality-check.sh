#!/bin/bash
# 告警质量周检（TEST-07 TC-OBS-07 执行器）
# 用法: alert-quality-check.sh [--week]；依赖 amtool（可选）/kubectl 或静态配置目录
set -u
MODE=${1:-"--week"}
RULES_DIR=${RULES_DIR:-"config/prometheus"}
echo "=== 告警质量检查（$MODE）==="
ISSUES=0

# 1. 无 runbook 的告警（annotations 缺少 runbook 字段）
if [ -d "$RULES_DIR" ]; then
  echo "[检查] 规则文件中的 runbook 覆盖..."
  while IFS= read -r f; do
    alerts=$(grep -c '^  - alert:' "$f" 2>/dev/null || echo 0)
    runbooks=$(grep -c 'runbook:' "$f" 2>/dev/null || echo 0)
    echo "  $f: 告警 $alerts 条 / runbook $runbooks 条"
    if [ "$runbooks" -lt "$alerts" ]; then
      echo "  ⚠️  $(($alerts - runbooks)) 条告警缺 runbook 链接"
      ISSUES=$((ISSUES+1))
    fi
  done < <(find "$RULES_DIR" -name '*.yml' -o -name '*.yaml' 2>/dev/null)
else
  echo "  [跳过] 规则目录 $RULES_DIR 不存在（设置 RULES_DIR 环境变量）"
fi

# 2. 静默超期检查（Alertmanager API）
AM_URL=${AM_URL:-"http://localhost:9093"}
echo "[检查] Alertmanager 静默（$AM_URL）..."
if curl -s --max-time 5 "$AM_URL/api/v1/silences" >/dev/null 2>&1; then
  now=$(date +%s)
  curl -s "$AM_URL/api/v1/silences" | grep -o '"endsAt":"[^"]*"' | cut -d'"' -f4 | while read -r end; do
    end_epoch=$(date -d "$end" +%s 2>/dev/null || echo "$now")
    [ "$end_epoch" -lt "$now" ] && echo "  ⚠️  存在已到期但未清除的静默: $end"
  done
  expired=$(curl -s "$AM_URL/api/v1/silences" | grep -o '"endsAt":"[^"]*"' | cut -d'"' -f4 | while read -r end; do
    end_epoch=$(date -d "$end" +%s 2>/dev/null || echo 0); now=$(date +%s)
    [ "$end_epoch" -lt "$now" ] && echo x; done | wc -l)
  echo "  已到期静默: ${expired} 条"
  [ "${expired:-0}" -gt 0 ] && ISSUES=$((ISSUES+1))
else
  echo "  [跳过] Alertmanager 不可达（TC-OBS-04 告警链路用例另行覆盖）"
fi

echo "============================="
[ "$ISSUES" -eq 0 ] && echo "✅ 告警质量检查通过" || echo "❌ $ISSUES 类问题待处理"
exit $([ "$ISSUES" -gt 0 ] && echo 1 || echo 0)
