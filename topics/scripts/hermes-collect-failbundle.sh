#!/usr/bin/env bash
# hermes 失败收集包脚本（TEST-11 §T.11.5 实现）
# 用法：hermes-collect-failbundle.sh PLAN_ID ENV CASE_ID
# 环境变量：RUNTIME=docker|podman（默认 docker）
# 产物：results/$PLAN_ID/$ENV-$CASE_ID.failbundle/{container-logs,resource-snapshot}/ + diagnose-labels.txt
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUNTIME="${RUNTIME:-docker}"

usage() {
  cat <<'EOF'
用法: hermes-collect-failbundle.sh PLAN_ID ENV CASE_ID
  PLAN_ID   任务包 ID
  ENV       环境标记，如 E2
  CASE_ID   用例 ID，如 TC-DEP-01
环境变量:
  RUNTIME=docker|podman
EOF
}

if [[ "$#" -lt 3 ]] || [[ "$1" == "--help" || "$1" == "-h" ]]; then
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage; exit 0
  fi
  echo "[ERROR] 参数不足"; usage; exit 2
fi

PLAN_ID="$1"
ENV="$2"
CASE_ID="$3"

BUNDLE="$PROJECT_ROOT/results/$PLAN_ID/$ENV-$CASE_ID.failbundle"
mkdir -p "$BUNDLE"/{container-logs,resource-snapshot}

COLLECTED=0

# 容器日志（兼容 docker/podman）
if command -v "$RUNTIME" >/dev/null 2>&1; then
  $RUNTIME ps -a --format '{{.Names}}' 2>/dev/null | grep -Ei "$CASE_ID|mq-test|hermes" | while read -r c; do
    [[ -z "$c" ]] && continue
    if $RUNTIME logs --tail 200 "$c" > "$BUNDLE/container-logs/$c.log" 2>&1; then
      COLLECTED=$((COLLECTED + 1))
    fi
  done
fi

# 资源快照
if command -v df >/dev/null 2>&1; then
  df -h > "$BUNDLE/resource-snapshot/df.txt" 2>&1
  COLLECTED=$((COLLECTED + 1))
fi

if command -v ps >/dev/null 2>&1; then
  ps aux > "$BUNDLE/resource-snapshot/ps.txt" 2>&1 || ps -ef > "$BUNDLE/resource-snapshot/ps.txt" 2>&1
  COLLECTED=$((COLLECTED + 1))
fi

if command -v "$RUNTIME" >/dev/null 2>&1; then
  $RUNTIME ps -a > "$BUNDLE/resource-snapshot/${RUNTIME}-ps.txt" 2>&1 || true
  $RUNTIME network ls > "$BUNDLE/resource-snapshot/${RUNTIME}-network-ls.txt" 2>&1 || true
  COLLECTED=$((COLLECTED + 2))
fi

# 诊断标签（调用同目录下的 hermes-diagnose.sh）
DIAGNOSE_SCRIPT="$SCRIPT_DIR/hermes-diagnose.sh"
if [[ -x "$DIAGNOSE_SCRIPT" ]]; then
  PLAN_ID="$PLAN_ID" RUNTIME="$RUNTIME" "$DIAGNOSE_SCRIPT" "$CASE_ID" "$ENV" > "$BUNDLE/diagnose-labels.txt" 2>&1
  COLLECTED=$((COLLECTED + 1))
fi

# 统计实际文件数（排除目录）
FILE_COUNT=$(find "$BUNDLE" -type f | wc -l)

echo "BUNDLE_PATH=$BUNDLE"
echo "FILES_COLLECTED=$FILE_COUNT"
